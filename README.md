# WebBrowser（iOS）[![GitHub license](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://github.com/avito-tech/Marshroute/blob/master/LICENSE)  [![carthage compatible](https://img.shields.io/badge/Carthage-compatible-blue.svg)](https://github.com/Carthage/Carthage) [![Build Status](https://travis-ci.org/zhongwuzw/WebBrowser.svg?branch=master)](https://travis-ci.org/zhongwuzw/WebBrowser)

一款用于网页浏览的APP（Web Browser For iOS)。[Github地址](https://github.com/zhongwuzw/WebBrowser)

## Features - 功能
1. 多Tab页浏览(multi-tab browsing)
2. 冷启动恢复浏览记录，包括当前页及前进后退页面(session restore, includes current page and backforward list)
3. 书签、历史记录管理(bookmark、history manage)
4. 页内查找(find in page)
5. 点击标题栏进行页面访问或搜索(tap the title bar to  input url for surf or key to search)
6. 自动监控剪切板`URL`，可在新窗口中打开

  
## Usage - 用法
  1. `clone` or download zip file.
  2. Run command `carthage update --platform iOS`
  3. Just run WebBrowser.xcodeproj
  
## Requirements - 依赖
* iOS 8.0 or higher
* ARC
* [Carthage](https://github.com/Carthage/Carthage)

## Demo
#### 1. Home Page (主页)：
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/home_scroll.gif" alt="home page"/>
</p>


#### 2. Multi-tab (多窗口)：
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/home_tab_switch.gif" alt="tab"/>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/tab_manage.gif" alt="tab"/>
</p>

#### 3. Search (搜索)：
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/home_search.gif" alt="search"/>
</p>

#### 4. No Image Mode (无图模式)
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/no-image-mode.gif" alt="no image mode"/>
</p>

#### 5. History (历史)
1. Long Press to select options. (长按记录可弹出选项按钮)
2. Tap to open history in current window.(点击记录会在当前窗口打开历史页面)
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/history.gif" alt="history"/>
</p>

#### 6. Favorite (收藏)
##### In non-editing mode (在非编辑模式下操作)
1. Long press on directory to edit directory name in non-editing mode.(长按目录来编辑目录名字)
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/bookmark_edit_long_section.gif" alt="favorite"/>
</p>

2. Long press on bookmark item to edit bookmark's url, name, directory in non-editing mode.(长按书签项来编辑书签的地址、名字、以及所在目录)
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/bookmark_long_edit_item.gif" alt="favorite"/>
</p>

##### In editing mode (在编辑模式下)
1. reorder, delete directory in editing mode.(删除、排序目录)
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/bookmark_edit_section.gif" alt="favorite"/>
</p>

2. click "新文件夹" button to add new directory in editing mode.(点击"新文件夹"按钮来创建新的目录)
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/bookmark_add_section.gif" alt="favorite"/>
</p>

3. reorder, delete bookmark in editing mode.(删除、排序书签)
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/bookmark_edit_item.gif" alt="favorite"/>
</p>

4. add new bookmark.(添加新书签)
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/bookmark_add.gif" alt="favorite"/>
</p>

#### 7. find in page (页内查找)
<p align="center">
  <img src="https://raw.githubusercontent.com/zhongwuzw/WebBrowser/master/images/findinpage.gif" alt="find in page"/>
</p>

## License

The MIT License (MIT)

Copyright (c) 2017 Zhong Wu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

