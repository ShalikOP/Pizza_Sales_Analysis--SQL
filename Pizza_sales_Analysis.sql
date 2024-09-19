-- Retrieve the total number of orders placed.
select count(order_id) as Total_Orders from orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS Total_price
FROM
    order_details AS od
JOIN
    pizzas AS p 
ON 
    od.pizza_id = p.pizza_id;
    
-- Identify the highest-priced pizza.
SELECT 
    pt.name,
    p.price
FROM
    pizzas AS p
JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY 
	p.price desc
limit 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    order_details AS od
JOIN
    pizzas AS p 
USING (pizza_id)
GROUP BY p.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS Quantity_sold
FROM
    order_details AS od
JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
JOIN
    pizza_types AS pt USING (pizza_type_id)
GROUP BY pt.name
ORDER BY Quantity_sold DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS Quantity_sold
FROM
    order_details AS od
JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
JOIN
    pizza_types AS pt USING (pizza_type_id)
GROUP BY pt.category
ORDER BY Quantity_sold DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hour,
    COUNT(order_id) as Order_Count
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity),2) AS Avg_Pizza_Orders_Per_Day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
	FROM
        order_details AS od
    JOIN orders AS o USING (order_id)
    GROUP BY o.order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name,
    ROUND(SUM((od.quantity * p.price)), 2) AS revenue
FROM
    order_details AS od
JOIN
    pizzas AS p USING (pizza_id)
JOIN
    pizza_types AS pt USING (pizza_type_id)
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(SUM((od.quantity * p.price)) / (SELECT 
                    SUM(od.quantity * p.price) AS Total_price
                FROM
                    order_details AS od
                        JOIN
                    pizzas AS p ON od.pizza_id = p.pizza_id)*100,
            2) AS Revenue_Percentage
FROM
    order_details AS od
JOIN
    pizzas AS p USING (pizza_id)
JOIN
    pizza_types AS pt USING (pizza_type_id)
GROUP BY pt.category
ORDER BY Revenue_Percentage DESC;

-- Analyze the cumulative revenue generated over time.

SELECT 
	order_date, 
	Round(sum(revenue) OVER(ORDER BY order_date),2) AS Cumulative_Revenue
FROM
	(SELECT 
		o.order_date,
		ROUND(SUM(od.quantity * p.price), 2) AS revenue
	FROM
		orders AS o
			JOIN
		order_details AS od USING (order_id)
			JOIN
		pizzas AS p USING (pizza_id)
	GROUP BY o.order_date) AS Per_Day_Revenue;