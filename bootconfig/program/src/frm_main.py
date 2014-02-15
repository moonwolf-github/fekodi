'''
Created on 15-02-2014

@author: moonwolf
'''

from Ui_tfrm_main import Ui_MainWindow
#from PyQt4 import QtGui, QtCore
#from PyQt4.QtCore import pyqtSignature
from PyQt4.QtGui import QMainWindow

class frm_Main(QMainWindow, Ui_MainWindow):
    '''
    classdocs
    '''

    def __init__(self, parent = None, name = None, fl = 0):
        '''
        Constructor
        '''
        QMainWindow.__init__(self, parent)
        self.setupUi(self)
        