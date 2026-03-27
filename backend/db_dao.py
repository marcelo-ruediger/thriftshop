from abc import ABC, abstractmethod
import mysql.connector

class MyDAOInterface(ABC):
    @abstractmethod
    def get_all(self):
        pass

    @abstractmethod
    def save(self, produkt):
        pass


class MySQLDAO(MyDAOInterface):
    conn = mysql.connector.connect()
    def get_all(self):
        

        return 