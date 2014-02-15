#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Created on 15-02-2014

@author: moonwolf
'''
import sys
from PyQt4 import Qt
import src.frm_main

def main(args):
    app=Qt.QApplication(args)
    #app.appTitle = title
    app.connect(app, Qt.SIGNAL("lastWindowClosed()"), app, Qt.SLOT("quit()"))
    
    mainWindow = src.frm_main.frm_Main()
    mainWindow.showMaximized()
    app.exec_()

if __name__ == '__main__':
    main(sys.argv)
