//
// LaunchBar Action
// default.js
//
// Copyright (c) 2014-2017 Objective Development
// https://obdev.at/
//


function runWithString(argument)
{
    LaunchBar.openURL('http://search.bilibili.com/all?keyword=' + encodeURIComponent(argument));
}

function run(){
    if (LaunchBar.options.commandKey == 1){
        LaunchBar.openURL('http://t.bilibili.com/')
    }
    else{
        LaunchBar.openURL('https://www.bilibili.com')
    }
}

