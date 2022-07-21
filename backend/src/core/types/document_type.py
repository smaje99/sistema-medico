from enum import Enum


class DocumentType(str, Enum):
    RC = 'R.C.'
    TI = 'T.I.'
    CC = 'C.C.'
    CE = 'C.E.'
