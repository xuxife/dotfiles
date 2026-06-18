function cde-connect --description 'Connect to a headless Linux CDE via Azure Bastion tunnel + ssh'
    set -l arg $argv[1]
    if test -z "$arg"
        echo "Usage: cde-connect <CdeId | name-substring>"
        echo "Example: cde-connect devbox-arm"
        return 1
    end

    # Resolve CdeId: accept a full uuid, otherwise match a session-name substring via `cde ls`.
    set -l cid
    if string match -qr '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-' -- $arg
        set cid $arg
    else
        set cid (cde ls 2>/dev/null | python3 -c '
import json,sys,re
arg=sys.argv[1].lower()
try: data=json.load(sys.stdin)
except Exception: data=[]
m=[s for s in data if arg in str(s.get("CDEName","")).lower()]
print(m[0]["CdeId"] if len(m)==1 else "")
' $arg)
        if test -z "$cid"
            echo "cde-connect: could not uniquely resolve '$arg' to a CdeId. Use `cde ls` and pass the CdeId."
            return 1
        end
    end

    set -l details "$HOME/.local/share/microsoft/cdp/MyCDEDetails_$cid.json"
    if not test -f $details
        echo "cde-connect: details file not found: $details"
        echo "Run `cde show -c $cid` once to populate it, then retry."
        return 1
    end

    # Pull VM/bastion/connection params out of the cached details file.
    set -l info (python3 -c '
import json,sys
d=json.load(open(sys.argv[1]))
sc=d["connection"]["sshConnection"]
vm=sc["virtualMachineResource"]; ba=sc["bastionResource"]
vmid="/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/virtualMachines/%s"%(vm["subscriptionId"],vm["resourceGroupName"],vm["name"])
print(vm["subscriptionId"]); print(ba["name"]); print(ba["resourceGroupName"]); print(vmid)
print(sc.get("user","")); print(sc.get("port",22))
' $details)
    set -l sub $info[1]
    set -l bastion $info[2]
    set -l bastion_rg $info[3]
    set -l vmid $info[4]
    set -l user $info[5]
    set -l rport $info[6]

    # Local tunnel port + identity come from the ssh config alias cde wrote (matched by HostKeyAlias).
    set -l lport (awk -v id="$cid" '
        /^[Hh]ost / {inblk=0; port=""}
        $1 ~ /^[Pp]ort$/ {port=$2}
        $0 ~ id {if(port!="") print port}
    ' "$HOME/.ssh/config" | head -1)
    set -l key "$HOME/.ssh/wave/$cid"
    if test -z "$lport"
        echo "cde-connect: no local Port found in ~/.ssh/config for $cid. Run `cde ssh -c $cid` once to seed it."
        return 1
    end
    if not test -f $key
        echo "cde-connect: ssh key not found: $key"
        return 1
    end

    # Start the bastion tunnel only if the local port is not already listening.
    if not ss -tlnH "sport = :$lport" 2>/dev/null | grep -q ":$lport"
        set -l tlog "/tmp/cde-bastion-$cid.log"
        echo "cde-connect: starting bastion tunnel on 127.0.0.1:$lport ..."
        setsid az network bastion tunnel --name $bastion --resource-group $bastion_rg \
            --subscription $sub --target-resource-id $vmid \
            --resource-port $rport --port $lport >$tlog 2>&1 &
        disown 2>/dev/null
        for i in (seq 1 30)
            if ss -tlnH "sport = :$lport" 2>/dev/null | grep -q ":$lport"
                break
            end
            sleep 1
        end
        if not ss -tlnH "sport = :$lport" 2>/dev/null | grep -q ":$lport"
            echo "cde-connect: tunnel did not come up. See $tlog"
            cat $tlog
            return 1
        end
    else
        echo "cde-connect: reusing existing tunnel on 127.0.0.1:$lport"
    end

    echo "cde-connect: connecting to $user@$cid ..."
    ssh -o StrictHostKeyChecking=accept-new \
        -o UserKnownHostsFile="$HOME/.ssh/known_hosts_cde" \
        -i $key -p $lport $user@127.0.0.1
end
