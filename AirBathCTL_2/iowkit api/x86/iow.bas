Attribute VB_Name = "iow"

' Required kernel32 functions
Public Declare Function GetLastError _
    Lib "kernel32" () _
As Long

' IOW SDK V1.5

' IO-Warrior vendor & product IDs
Public Const IOWKIT_VENDOR_ID As Long = &H7C0
Public Const IOWKIT_VID As Long = IOWKIT_VENDOR_ID

' IO-Warrior 40
Public Const IOWKIT_PRODUCT_ID_IOW40 As Long = &H1500
Public Const IOWKIT_PID_IOW40 As Long = IOWKIT_PRODUCT_ID_IOW40

' IO-Warrior 24
Public Const IOWKIT_PRODUCT_ID_IOW24 As Long = &H1501
Public Const IOWKIT_PID_IOW24 As Long = IOWKIT_PRODUCT_ID_IOW24

' IO-Warrior PowerVampire
Public Const IOWKIT_PRODUCT_ID_IOWPV1 As Long = &H1511
Public Const IOWKIT_PID_IOWPV1 As Long = IOWKIT_PRODUCT_ID_IOWPV1
Public Const IOWKIT_PRODUCT_ID_IOWPV2 As Long = &H1512
Public Const IOWKIT_PID_IOWPV2 As Long = IOWKIT_PRODUCT_ID_IOWPV2

' IO-Warrior 56
Public Const IOWKIT_PRODUCT_ID_IOW56 As Long = &H1503
Public Const IOWKIT_PID_IOW56 As Long = IOWKIT_PRODUCT_ID_IOW56

' Max number of pipes per IOW device
Public Const IOWKIT_MAX_PIPES As Long = 2

' pipe names
Public Const IOW_PIPE_IO_PINS As Long = 0
Public Const IOW_PIPE_SPECIAL_MODE As Long = 1

' Max number of IOW devices in system
Public Const IOWKIT_MAX_DEVICES As Long = 16

' IOW Legacy devices open modes
Public Const IOW_OPEN_SIMPLE As Long = 1
Public Const IOW_OPEN_COMPLEX As Long = 2

' first IO-Warrior revision with serial numbers
Public Const IOW_NON_LEGACY_REVISION = &H1010

' IO-Warrior low-level library API functions

Public Declare Function IowKitOpenDevice _
    Lib "iowkit" () _
As Long

Public Declare Sub IowKitCloseDevice _
    Lib "iowkit" _
    (ByVal iowHandle As Long)

Public Declare Function IowKitWrite _
    Lib "iowkit" _
    (ByVal iowHandle As Long, _
     ByVal numPipe As Long, _
     ByRef buffer As Byte, _
     ByVal length As Long _
    ) _
As Long

Public Declare Function IowKitRead _
    Lib "iowkit" _
    (ByVal iowHandle As Long, _
     ByVal numPipe As Long, _
     ByRef buffer As Byte, _
     ByVal length As Long _
    ) _
As Long

Public Declare Function IowKitReadNonBlocking _
    Lib "iowkit" _
    (ByVal iowHandle As Long, _
     ByVal numPipe As Long, _
     ByRef buffer As Byte, _
     ByVal length As Long _
    ) _
As Long

Public Declare Function IowKitReadImmediate _
    Lib "iowkit" _
    (ByVal iowHandle As Long, _
     ByRef Value As Long) _
As Long

' Get number of IOW devices
Public Declare Function IowKitGetNumDevs _
    Lib "iowkit" () _
As Long

' Get Nth IOW device handle
Public Declare Function IowKitGetDeviceHandle _
    Lib "iowkit" _
    (ByVal numDevice As Long) _
As Long

Public Declare Function IowKitSetLegacyOpenMode _
    Lib "iowkit" _
    (ByVal openMode As Long) _
As Long

Public Declare Function IowKitGetProductId _
    Lib "iowkit" _
    (ByVal iowHandle As Long) _
As Long

Public Declare Function IowKitGetRevision _
    Lib "iowkit" _
    (ByVal iowHandle As Long) _
As Long

Public Declare Function IowKitGetThreadHandle _
    Lib "iowkit" _
    (ByVal iowHandle As Long) _
As Long

Public Declare Function IowKitGetSerialNumber _
    Lib "iowkit" _
    (ByVal iowHandle As Long, ByRef serialNumber As Byte) _
As Long

Public Declare Function IowKitSetTimeout _
    Lib "iowkit" _
    (ByVal iowHandle As Long, ByVal TimeOut As Long) _
As Long

Public Declare Function IowKitSetWriteTimeout _
    Lib "iowkit" _
    (ByVal iowHandle As Long, ByVal TimeOut As Long) _
As Long

Public Declare Function IowKitCancelIo _
    Lib "iowkit" _
    (ByVal iowHandle As Long, _
     ByVal numPipe As Long) _
As Long

