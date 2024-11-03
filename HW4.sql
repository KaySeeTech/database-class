/*  -- table fixing 
select constraint_name 
from information_schema.key_column_usage 
where table_name = 'customer' 
andcolumn_name = 'address_id';

alter table staff
modify address_id integer;
*/

-- primary and foreign keys
alter table actor
add primary key(actor_id);

alter table address
add primary key(address_id);

alter table address -- a
add foreign key(city_id) references city(city_id);

alter table category
add primary key(category_id);

alter table category
add constraint category_constaint
check (name in ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 'Children', 'Drama', 'Horror', 'Action', 'Classics', 'Games', 'New', 'Documentary', 'Sports', 'Music'));

alter table city
add primary key(city_id);

alter table cityinventory
add foreign key(country_id) references country(country_id);

alter table country
add primary key(country_id);

alter table customer
add primary key(customer_id);

alter table customer
add foreign key(store_id) references store(store_id); 

alter table customer
add foreign key(address_id) references address(address_id);

alter table customer
add constraint active_constraint 
check (active in (0, 1));

alter table film
add primary key(film_id);

alter table film
add foreign key(language_id) references language(language_id);

alter table film 
add constraint special_features_constaint
check (special_features in ('Behind the Scenes', 'Commentaries', 'Deleted Scenes', 'Trailers'));

alter table film
add constraint rental_rate_constraint
check (rental_rate between 0.99 and 6.99);

alter table film
add constraint film_length_constraint
check (length between 30 and 200);

alter table film 
add constraint rating_constraint
check (rating in ('PG', 'G', 'NC-17', 'PG-13', 'R'));

alter table film
add constraint replacement_cost_constraint
check (replacement_cost between 5.00 and 100.00);

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

alter table inventory
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

alter table payment
add constraint amount_constraint
check (amount >= 0);

alter table rental
add primary key(rental_id);
-- ask about unique keys in here below
alter table rental
add foreign key(inventory_id) references inventory(inventory_id);

alter table rental
add foreign key(customer_id) references customer(customer_id);

alter table rental
add foreign key(staff_id) references staff(staff_id);

alter table rental -- ????
add constraint rental_date_unique unique (rental_date);

alter table rental -- ????
add constraint customer_id_unique unique (customer_id);

alter table rental -- ????
add constraint rental_date_unique unique (rental_date);

alter table staff
add primary key(staff_id);

alter table staff
add foreign key(address_id) references address(address_id);

alter table staff
add foreign key(store_id) references store(store_id);

alter table staff
add constraint staff_active_constraint 
check (active in (0, 1));

alter table store
add primary key(store_id);

alter table store
add foreign key(address_id) references address(address_id);

select store.address_id
from store;

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
select customer.customer_id, customer.first_name,customer.last_name
from rental
inner join customer on rental.customer_id = customer.customer_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
where category.name = 'action'
except
select customer.customer_id, customer.first_name,customer.last_name
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
/* -- sanity check
select count(distinct film.title), staff.staff_id,staff.first_name
from address
inner join staff on address.address_id = staff.address_id
inner join store on staff.store_id = store.store_id
inner join inventory on store.store_id = inventory.store_id
inner join rental on inventory.inventory_id = rental.inventory_id
inner join film on inventory.film_id = film.film_id
group by staff.staff_id,staff.first_name;
*/

select count(distinct film.film_id) as films  -- get a count of distinct films from whom they were rented from
from address
inner join staff on address.address_id = staff.address_id
inner join store on staff.store_id = store.store_id
inner join inventory on store.store_id = inventory.store_id
inner join rental on inventory.inventory_id = rental.inventory_id
inner join film on inventory.film_id = film.film_id  -- join tables
where datediff(return_date,rental_date) = 10 and staff.staff_id = 1;  -- get the difference in days that is equal to 10 days and staff member is Mike

-- Query 6: Alphabetically list actors who appeared in the movie with the largest cast of actors.
with ActorCast as  -- create a subtable of the count of each actor in each film
(select film.title as title,count(distinct actor.actor_id) as cast_size
from film_actor
inner join actor on film_actor.actor_id = actor.actor_id
inner join film on film_actor.film_id = film.film_id  -- join tables
group by film.title),  -- sort by films

ActorList as  -- use this subtable to find the film with the most actors
(select ActorCast.title,cast_size
from ActorCast
where cast_size = (select max(cast_size) from ActorCast))  -- filters out row to get film with most actor

select actor.first_name,actor.last_name  -- select names of each actor in film
from ActorList
inner join film on ActorList.title = film.title
inner join film_actor on film.film_id = film_actor.film_id
inner join actor on film_actor.actor_id = actor.actor_id -- join the ActorList table with the film, film_actor, and actor to bring info about each actor in the film
order by actor.last_name;  -- sort alphabetically by last name






