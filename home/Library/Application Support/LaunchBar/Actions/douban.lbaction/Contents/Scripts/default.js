//
// LaunchBar Action
// default.js
//
// Copyright (c) 2014-2017 Objective Development
// https://obdev.at/
//


douban_dict = {
  'mv': 'movie',
  'ms': 'music',
  'bk': 'book'
}

function runWithString(argument)
{
  pre = argument.slice(0,2)
  if (pre in douban_dict){
    LaunchBar.openURL('https://' + douban_dict[pre] + '.douban.com/subject_search?search_text=' + encodeURIComponent(argument.slice(2)));
  }
  else{
    LaunchBar.openURL('https://www.douban.com/search?q=' + encodeURIComponent(argument));
  }
}

function run(){
    LaunchBar.openURL('http://www.douban.com')
}

