//
// Youtube
// LaunchBar Action
// default.js
//
// Copyright (c) 2014-2017 Objective Development
// https://obdev.at/
//


function runWithString(argument)
{
    LaunchBar.openURL('https://www.youtube.com/results?search_query=' + encodeURIComponent(argument));
}

function run(){
    LaunchBar.openURL('https://www.youtube.com')
}
