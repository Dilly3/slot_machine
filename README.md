# Food_Truck
### This script is a program for a food dispencer (Food Truck)
# Run the script either as an admin or a customer

```bash
./food_truck.sh admin
```
### OR
```bash
./food_truck.sh customer
```

- ## Admin User:
###   Admin user takes inventory and update stock of food available
- ## Customer User:
###   Customer User makes order according to what is available in the menu.
###   If the desired meal and the required quantity is available in stock, then customer order is taken and processed.


## Architecture
### Two files are created when the program is run for the first time
- ### food-options.txt
>> #### this is where is food available are stored
- ### food_stock.txt
>> #### this is where the food and the quantity available for each food is stored
### Only admin user can update these files.

### When the program is run for the first time, the food menu is empty.
### Admin user will have to update menu first.
### Run as Admin 
```bash
./food_truck.sh admin
```

### After the menu has been Updated , customer can make order.
### Run as Customer

```bash
./food_truck.sh customer
```
### When the customer order is received and processed, the ```food_options.txt``` and the ```food_stock.txt``` files are updated accordingly.
## Author
- ### Name: Michael Olisa. A 
- ### Email: michael.anikamadu@gmail.com
- ### Github: [Dilly3](https://github.com/Dilly3)
- ### Linkedin: [michael-olisa](https://linkedin.com/in/michael-olisa)



