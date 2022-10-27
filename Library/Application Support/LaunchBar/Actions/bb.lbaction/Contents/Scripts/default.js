//
// sspai
// LaunchBar Action
// default.js
//
// Copyright (c) 2014-2017 Objective Development
// https://obdev.at/
//

//course_dict = {
//  'e': '1005',
//  'en': '1005',
//  'ge': '900',
//  'ga': '900',
//  'gea': '900',
//  'ts': '989',
//  'si': '961',
//  '32': '961',
//  'ra': '960',
//  '31': '960',
//  'bi': '859',
//  'bio': '859',
//  'bme': '1082',
//  'bm': '1082',
//  'op': '1076',
//  'om': '1076',
//}

//course = {
//    'pc': '151',
//    'im': '232',
//    'dm': '243',
//    'ns': '331',
//    'sp': '334',
//    'cd': '337'
//}

// course = {
//     'dm': '1164',
//     'wa': '1190',
//     'de': '1470',
//     'ss': '1150',
//     'ts': '1148'
// }

// cmp = {
//     'dm': '2244',
//     'wa': '2270',
//     'de': '2645',
//     'ss': '2230',
//     'ts': '2228'
// }

// course = {
//   'fm': '1972',
//   'cc': '1917',
//   'ds': '2151',
//   'na': '2021',
// }

// cmp = {
//   'fm': '3774',
//   'cc': '3719',
//   'ds': '3972',
//   'na': '3823',
// }

course = {
  'pp': 2603,
  'ml': 2608,
  'gt': 2804,
}

cmp = {
  'pp': 5129,
  'ml': 5134,
  'gt': 5330,
}

function runWithString(argument) {
  if (argument in course) {
    LaunchBar.openURL('https://bb.cuhk.edu.cn/webapps/blackboard/execute/modulepage/view?course_id=_' + encodeURIComponent(course[argument]) + '_1&cmp_tab_id=_' + encodeURIComponent(cmp[argument]) + '_1&mode=view');
  }
}

function run() {
  LaunchBar.openURL('https://bb.cuhk.edu.cn/webapps/portal/execute/tabs/tabAction?tab_tab_group_id=_1_1')
}
