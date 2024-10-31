-- primary and foreign keys
rename database hw4 to testing;

alter table actor
add primary key(actor_id);

alter table address
add primary key(address_id);

alter table address  -- add this
add foreign key(city_id) references city(city_id);

alter table category
add primary key(category_id);

alter table city
add primary key(city_id);

alter table city
add foreign key(country_id) references country(country_id);

alter table customer
add primary key(customer_id);

alter table customer  -- add this
add foreign key(store_id) references store(store_id); 

alter table customer
add foreign key(address_id) references address(address_id);

alter table film
add primary key(film_id);

alter table film
add foreign key(language_id) references language(language_id);

alter table film_actor
add foreign key (actor_id) references actor(actor_id);

alter table film_actor
add foreign key (film_id) references film(film_id);

alter table film_category
add foreign key(film_id) references film(film_id);

alter table film_category
add foreign key(category_id) references category(category_id);

alter table inventory
add primary key(inventory_id);

alter table inventory
add foreign key(film_id) references film(film_id);

alter table inventory -- add this when store is added
add foreign key(store_id) references store(store_id);

alter table language
add primary key(language_id);

alter table payment
add primary key(payment_id);

alter table payment
add foreign key(customer_id) references customer(customer_id);

alter table payment  -- add this
add foreign key(staff_id) references staff(staff_id);

alter table payment  -- add this
add foreign key(rental_id) references rental(rental_id);

alter table rental
add primary key(rental_id);
-- ask about unique keys in here below
alter table rental  -- add once disclosed
add foreign key(inventory_id) references inventory(inventory_id);

alter table rental  -- add
add foreign key(customer_id) references customer(customer_id);

alter table rental
add foreign key(staff_id) references staff(staff_id);

alter table staff
add primary key(staff_id);

alter table staff  -- add this
add foreign key(address_id) references address(address_id);

alter table staff
modify address_id integer;

alter table staff  -- add this
add foreign key(store_id) references store(store_id);

alter table store
add primary key(store_id);

alter table store  -- isues with this
add foreign key(address_id) references address(address_id);

select store.address_id
from store;

select address.address_id
from address
where address.address_id = '10';


SELECT address_id 
FROM store
WHERE address_id NOT IN (SELECT address_id FROM address);
-- address is wack, fix it
-- add constraints

-- Query 1: What is the average length of films in each category? List the results in alphabetic order of categories.
select category.name, avg(film.length) as avg_film_length  -- get average of each film from each category
from film_category
inner join film on film_category.film_id = film.film_id  -- join two tables to find category and film
inner join category on film_category.category_id = category.category_id
group by category.name  -- group by category and alphabetize them
order by category.name;

-- Query 2: Which categories have the longest and shortest average film lengths?
with CategoryGroups as  -- Create a sub table with the category of each film with the average length of film
(select category.name as category, avg(film.length) film_length
from film_category
inner join film on film_category.film_id = film.film_id
inner join category on film_category.category_id = category.category_id  -- join two tables
group by category.name)

select category,film_length  -- select category and average film lengths
from CategoryGroups
where film_length = (select max(film_length) from categorygroups)  -- set the film_length to be the max length from the subtable

union  -- combine both tables together

select category,film_length  -- select category and average film lengths
from CategoryGroups
where film_length = (select min(film_length) from categorygroups);  -- set the film_length to be the max length from the subtable

-- Query 3: Which customers have rented action but not comedy or classic movies?
select count(distinct customer.customer_id) as count
from rental
inner join customer on rental.customer_id = customer.customer_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
where category.name = 'action'
except
select count(distinct customer.customer_id)
from rental
inner join customer on rental.customer_id = customer.customer_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
where category.name = 'comedy' or category.name = 'classic';

-- Query 4: Which actor has appeared in the most English-language movies?
select actor.actor_id,actor.first_name,actor.last_name,count(film.film_id) as starred_in  -- get the count of every movie an actor was in
from film_actor
inner join actor on film_actor.actor_id = actor.actor_id
inner join film on film_actor.film_id = film.film_id
inner join language on film.language_id = language.language_id  -- join tables together
where language.name = 'English'  -- limit to movies that are in english
group by actor.actor_id
having (starred_in) >= all  -- filter each group to get most starred actor

	(select count(film.film_id)  -- same query as above for the subquery
	from film_actor
	inner join actor on film_actor.actor_id = actor.actor_id
	inner join film on film_actor.film_id = film.film_id
	inner join language on film.language_id = language.language_id
	where language.name = 'English'
    group by actor.actor_id);

-- Query 5: How many distinct movies were rented for exactly 10 days from the store where Mike works?
select staff.staff_id,staff.first_name
from address
inner join staff on address.address_id = staff.address_id;


