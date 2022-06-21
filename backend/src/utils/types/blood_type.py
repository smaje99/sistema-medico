from enum import Enum


class BloodType(str, Enum):
    ABp = 'AB+'
    ABa = 'AB-'
    Ap = 'A+'
    Aa = 'A-'
    Bp = 'B+'
    Ba = 'B-'
    Op = 'O+'
    Oa = 'O-'
