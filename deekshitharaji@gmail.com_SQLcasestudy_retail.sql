select * from customer
select * from prod_cat_info
select * from Transactions


select *
from customer c
inner join Transactions t on t.cust_id=c.customer_Id
	inner join prod_cat_info p on p.prod_cat_code=t.prod_cat_code


---Altering datatypes for Transaction
ALTER TABLE Transactions
ALTER COLUMN transaction_id bigint

ALTER TABLE Transactions
ALTER COLUMN Qty int

ALTER TABLE Transactions
ALTER COLUMN cust_id int

ALTER TABLE Transactions
ALTER COLUMN [prod_subcat_code] int

ALTER TABLE Transactions
ALTER COLUMN [prod_cat_code] float

ALTER TABLE Transactions
ALTER COLUMN Rate int


ALTER TABLE Transactions
ALTER COLUMN Tax float


ALTER TABLE Transactions
ALTER COLUMN Qty int
ALTER TABLE Transactions
ALTER COLUMN cust_id int

--changed datatype of tran_date while importing csv 
ALTER TABLE Transactions
ALTER COLUMN total_amt float


---Altering datatypes for [prod_cat_info]

ALTER TABLE prod_cat_info
ALTER COLUMN [prod_cat_code] int


ALTER TABLE prod_cat_info
ALTER COLUMN [prod_sub_cat_code] int


---Altering datatypes for [Customer]


ALTER TABLE Customer
ALTER COLUMN customer_Id int

ALTER TABLE Customer
ALTER COLUMN [city_code] int
--changed datatype of dob while importing csv 

----------------------------------------


--DATA PREPEARATION AND UNDERSTANDING

--Q1

---total rows in each tables

select count(customer_id)[total Rows in Customer] from Customer
select count(prod_cat_code)[total Rows in prod_cat_info] from prod_cat_info
select count(cust_id)[total Rows in Transactions ] from Transactions



---Q2



select count(transaction_id)[Total return transactions]
from Transactions
where sign(Rate)<0


 
---q3---

---Have already changed the datatype while importing tables as datetime for DOB and tran_date

select * from Transactions
select * from customer




-----Q4

select 
tran_date[Treansaction date],
year(tran_date)[Year],
month(tran_date)[Month],
day(tran_date)[day]
--min(tran_date)[Time range start],max(tran_date)[Time range end]
from Transactions
group by tran_date



----Q5

select prod_cat from prod_cat_info
where prod_subcat='DIY'



------------------DATA analysis

--Q1

select * from customer
select * from prod_cat_info
select * from Transactions

select  top 1 Store_type,count(transaction_id)[Most frequently used]
from Transactions
group by Store_type
order by count(Store_type) desc


--Q2

select Gender,count(Gender)[Count of Male and Female Customers]
from Customer where Gender in ('M','F')
group by Gender
order by Gender


---Q3

select top 1 city_code,count(customer_id)[Max customers] 
from Customer
group by city_code
order by count(customer_id) desc

----q4

select count(prod_subcat) [Sub category in books]--,prod_subcat,prod_cat
from prod_cat_info
where prod_cat='Books'
--group by prod_cat,prod_subcat

----Q5

select t.prod_cat_code,max(t.Qty)[max],pc.prod_cat
from Transactions t
inner join prod_cat_info pc on t.prod_cat_code=pc.prod_cat_code
where sign(t.Qty)>0
group by pc.prod_cat,t.prod_cat_code
order by max(t.Qty) desc





---q6

select pc.prod_cat,sum(t.total_amt) [total revenue]
from prod_cat_info pc
	inner join Transactions t on t.prod_cat_code=pc.prod_cat_code
where pc.prod_cat='Books' or pc.prod_cat='Electronics'
group by pc.prod_cat
order by sum(t.total_amt) desc


---q7 

select count(t1.cid)[Total customers]
from(
select distinct cust_id[cid],sum(Qty)[Total] 
from Transactions where sign(Qty)>0
group by cust_id,Qty
)t1
where t1.Total>10 


---q8


select sum(t.total_amt)[Total revenue]
from Transactions t
		inner join prod_cat_info pc on pc.prod_cat_code=t.prod_cat_code
		where t.Store_type='Flagship store' 
		and pc.prod_cat in ('Electronics','Clothing')and sign(t.total_amt)>0


----Q9




	
	select t.cust_id,c.Gender,p.prod_cat,p.prod_subcat,sum(t.total_amt)[Total revenue]
	from Customer c
				inner join Transactions t on t.cust_id=c.customer_Id
				inner join prod_cat_info p on p.prod_cat_code=t.prod_cat_code
				where c.Gender='M' and p.prod_cat='Electronics' and  sign(t.total_amt)>0
				group by t.cust_id,c.Gender,p.prod_cat,p.prod_subcat


---q10


		with cte(prod_subcat_code,total_amt,Qty)
		as(
		select prod_subcat_code,sum(total_amt),Qty as per
		from Transactions where sign(total_amt)<0
		group by prod_subcat_code,Qty
		)
		select top 5 cte.prod_subcat_code,
		cte.total_amt,
		cte.total_amt*100.0/(select sum(total_amt) from cte) as percentageofsales
		--cte.Qty*100.0/(select sum(total_amt) from cte) as percentageof
		from cte
		order by cte.total_amt desc

		
		
		


----q11

----creating new column for Age

ALTER TABLE Customer
ADD age INT;

-----calculating age using dob of customers

UPDATE Customer
SET age = abs(DATEDIFF(year,getdate(), DOB))



DECLARE @myvar Date
set @myvar = (select  max(tran_date) from Transactions)
select c.customer_Id,sum(t.total_amt)[Sales],c.age
from Customer c
				inner join Transactions t on t.cust_id=c.customer_Id
				inner join prod_cat_info p on p.prod_cat_code=t.prod_cat_code
				where c.age  between 25 and 35 and sign(t.total_amt)>0 
				group by c.customer_Id,t.total_amt,c.age,t.tran_date
				having t.tran_date>=Dateadd(DAY,-30,@myvar)
				order by c.customer_Id,sum(t.total_amt) ,c.age



---q12 

			DECLARE @myvar Date
				set @myvar = (select  max(tran_date) from Transactions)
				select top 1 p.prod_cat,max(t.total_amt)[Max value of return]
				from Customer c
				inner join Transactions t on t.cust_id=c.customer_Id
				inner join prod_cat_info p on p.prod_cat_code=t.prod_cat_code
				group by p.prod_cat,t.total_amt,t.tran_date
				having sign(t.total_amt)<0 and t.tran_date>=Dateadd(MONTH,-3,@myvar)
				order by max(t.total_amt) asc



---q13   

select top 1 Store_type,count(Qty)[Maximum products],sum(total_amt)[Total sales]
from Transactions where sign(total_amt)>0 and sign(Qty)>0
group by Store_type
order by count(Qty) desc,sum(total_amt) desc



----q14

	
			DECLARE @var Float
				set @var = (select  avg(total_amt) from Transactions)
				select p.prod_cat,avg(t.total_amt)[Average above overall average]
				from Transactions t
						inner join prod_cat_info p on p.prod_cat_code=t.prod_cat_code
						
				group by p.prod_cat
				having avg(t.total_amt)>@var
				order by avg(t.total_amt)


----q15


select top 5 p.prod_cat,
p.prod_subcat,
avg(t.total_amt)[Average amount],
sum(t.total_amt)[Total revenue],
count(t.Qty)[Quantity]
from Transactions t
			inner join prod_cat_info p on p.prod_cat_code=t.prod_cat_code
			where sign(t.Qty)>0
group by p.prod_cat,p.prod_subcat
order by p.prod_cat,p.prod_subcat,count(t.Qty) desc,avg(t.total_amt),sum(t.total_amt)
