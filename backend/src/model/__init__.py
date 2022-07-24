from sqlalchemy.orm import relationship

from .patient import Patient
from .person import Person


Patient.person = relationship(Person, back_populates='patient')
