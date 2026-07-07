# def add(*args):
#     sum = 0
#     for n in args:
#         sum +=n
#     print(sum)

# add(1,2,3,4,5,6,7,8,9,10)

def calculate(**kwargs):
    print(kwargs)




calculate(add=1, subtract=2, multply=3)

class Car:
    def __init__(self, **kw):
        self.make = kw.get("make")
        self.model = kw.get("model")
        self.color = kw.get("color")
        self.seats = kw.get("seats")

my_car = Car(make="Nissan", model="GTR", seats=2, color="red")

