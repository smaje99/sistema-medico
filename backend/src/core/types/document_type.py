from enum import Enum


class DocumentType(str, Enum):
    CIVIL_REGISTRATION = 'R.C.'
    IDENTITY_CARD = 'T.I.'
    CITIZENSHIP_CARD = 'C.C.'
    FOREIGN_CARD = 'C.E.'
