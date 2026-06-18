//
// sspai
// LaunchBar Action
// default.js
//
// Copyright (c) 2014-2017 Objective Development
// https://obdev.at/
//


function runWithString(argument)
{
    LaunchBar.openURL('https://sspai.com/search/?q=' + encodeURIComponent(argument));
}

function run(){
    LaunchBar.openURL('https://www.sspai.com')
}
