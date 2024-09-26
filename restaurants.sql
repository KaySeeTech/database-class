create database restaurants;

use restaurants;

select *
from works;

/* *******************************************************************************

    chefs (chefID, name, specialty)
    restaurants (restID, name, location)
    works (chefID, restID) - indicates which chef works at which restaurant
    foods (foodID, name, type, price) - information about each food item
    serves (restID, foodID, date_sold) - records of which foods are served at which restaurant
    
select foods.type, AVG(foods.price) as AvgPrice
from foods
group by foods.type;
******************************************************************************** */

-- query 1: Average Price of Foods at Each Restaurant
select restaurants.name, avg(foods.price) as AvgPrice  -- take average of place each food with its respective restaurant
from serves
inner join foods on serves.foodID = foods.foodID
inner join restaurants on serves.restID = restaurants.restID  -- both inner joins to connect restaurants and foods
group by restaurants.name;

-- query 2: Maximum Food Price at Each Restaurant
select restaurants.name, max(foods.price) as MaxPrice  -- take the max of place each food with its respective restaurant
from serves
inner join foods on serves.foodID = foods.foodID
inner join restaurants on serves.restID = restaurants.restID  -- both inner joins to connect restaurants and foods
group by restaurants.name;

-- query 3 Count of Different Food Types Served at Each Restaurant
select restaurants.name, count(distinct foods.type) as FoodTypes  -- use distinct to not count same food types twice
from serves
inner join foods on serves.foodID = foods.foodID
inner join restaurants on serves.restID = restaurants.restID -- both inner joins to connect restaurants and foods
group by restaurants.name;

-- query 4 Average Price of Foods Served by Each Chef
select chefs.name, avg(foods.price)  -- Calculate the average price of food each chef makes
from works
inner join chefs on works.chefID = chefs.chefID
inner join restaurants on works.restID = restaurants.restID  -- join chefs to restaurants throught works table
inner join serves on serves.restID = restaurants.restID  -- join restaurants table with serves table
inner join foods on foods.foodID = serves.foodID  -- join serves to foods table
group by chefs.name;

-- query 5 Find the Restaurant with the Highest Average Food Price
select restaurants.name, avg(foods.price) as MaxPrice -- Made as Max Price to make category for highest average food cost
from serves
inner join foods on serves.foodID = foods.foodID
inner join restaurants on serves.restID = restaurants.restID  -- both inner joins to connect restaurants and foods
group by restaurants.name
having (MaxPrice) >= all  -- condition to find the MaxPrice by comparing groups to MaxPrice

	-- form a subquery here create groups to compare to the Max Price
	(select avg(foods.price)  -- find the average cost of each food item for each restaurant
	from serves
	inner join foods on serves.foodID = foods.foodID
	inner join restaurants on serves.restID = restaurants.restID  -- once again join restaurants and foods with serves
	group by restaurants.name);
    
-- Query 6 Extra Credit: Determine which chef has the highest average price of the foods served at the restaurants where they work.
-- Include the chef’s name, the average food price, and the names of the restaurants where the chef works. 
-- Sort the  results by the average food price in descending order.
select chefs.name, restaurants.name, avg(foods.price) as AvgPrice -- Calculate the average price of food each chef makes
from works
inner join chefs on works.chefID = chefs.chefID
inner join restaurants on works.restID = restaurants.restID  -- join chefs to restaurants throught works table
inner join serves on serves.restID = restaurants.restID  -- join restaurants table with serves table
inner join foods on foods.foodID = serves.foodID  -- join serves to foods table
group by chefs.name, restaurants.name
having (AvgPrice) >= all

-- Create a subquery to find the prices of the foods and compare
	(select avg(foods.price) -- Calculate the average price of food each chef makes
	from works
	inner join chefs on works.chefID = chefs.chefID
	inner join restaurants on works.restID = restaurants.restID  -- join chefs to restaurants throught works table
	inner join serves on serves.restID = restaurants.restID  -- join restaurants table with serves table
	inner join foods on foods.foodID = serves.foodID  -- join serves to foods table
	group by chefs.name, restaurants.name);


    
    
    

	