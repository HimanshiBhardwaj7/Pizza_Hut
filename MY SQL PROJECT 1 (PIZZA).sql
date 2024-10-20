-- ---Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


-- ---Calculate the total revenue generated from pizza sales. 


SELECT 
    ROUND(SUM(orders_details.quanity * pizza.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizza ON pizza.pizza_id = orders_details.pizza_id;
    
    
--     Identify the highest priced pizza.


SELECT 
    pizza_types.name, pizza.price
FROM
    pizza_types
        JOIN
    pizza ON pizza.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizza.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.


SELECT 
    quanity, COUNT(order_details_id)
FROM
    orders_details
GROUP BY quanity;

SELECT 
    pizza.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizza
        JOIN
    orders_details ON pizza.pizza_id = orders_details.pizza_id
GROUP BY pizza.size
ORDER BY order_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.


SELECT 
    pizza_types.name, COUNT(orders_details.quanity) AS quanity
FROM
    pizza_types
        JOIN
    pizza ON pizza_types.pizza_type_id = pizza.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizza.pizza_id
GROUP BY pizza_types.name
ORDER BY quanity DESC
LIMIT 5;



-- Join the necessary tables to find the total quantity of each pizza category ordered.


SELECT 
    pizza_types.category,
    COUNT(orders_details.quanity) AS quantity
FROM
    pizza_types
        JOIN
    pizza ON pizza_types.pizza_type_id = pizza.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizza.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- Determine the distribution of orders by hours of the day.



SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevent tables to find the categorywise distribution of pizzas.


SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    round(AVG(quantity),0) as avg_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quanity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
    
--     Determine the top 3 most orderd pizza types based on revenue. 


SELECT 
    pizza_types.name,
    SUM(orders_details.quanity * pizza.price) AS revenue
FROM
    pizza_types
        JOIN
    pizza ON pizza_types.pizza_type_id = pizza.pizza_type_id
        JOIN
    orders_details ON orders_details.PIZZA_ID = pizza.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.


SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quanity * pizza.price) / (SELECT 
                    ROUND(SUM(orders_details.quanity * pizza.price),
                                2) AS total_sales
                FROM
                    orders_details
                        JOIN
                    pizza ON pizza.pizza_id = orders_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizza ON pizza_types.pizza_type_id = pizza.pizza_type_id
        JOIN
    orders_details ON orders_details.PIZZA_ID = pizza.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;



-- Analyze the cumulative revenue generated over time.

Select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from
(Select orders.order_date,
sum(orders_details.quanity*pizza.price) as revenue
from orders_details join pizza
on orders_details.pizza_id = pizza.pizza_id
join orders
on orders.order_id = orders_details.ORDER_ID
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


Select name, revenue
from
(Select category,name,revenue,
rank() over(partition by category order by revenue desc) As RN
FROM
(Select pizza_types.category, pizza_types.name,
sum((orders_details.quanity)*pizza.price)as revenue
from pizza_types join pizza
on pizza_types.pizza_type_id = pizza.pizza_type_id
join orders_details
on orders_details.PIZZA_ID = pizza.pizza_id
group by pizza_types.category, pizza_types.name) AS A) AS B
where RN <=3;