# Covid 19 Data Exploration and Analysis
## Overview
The objective of this repository was to explore and visualize Covid 19 data from around the world using SQL and Tableau.

The dataset was obtained from [Our World In Data](https://ourworldindata.org/covid-deaths) and retrieved on January 13, 2023. The dataset includes dozens of columns from hundreds of countries.

### Data Exploration
The data used can be found in the Raw Data folder. The original dataset gathered from Our World In Data is found in the owid-covid-data.zip as an Excel CSV. This data set was brought into Excel to examine the columns. Two different tables were created from this dataset; Covid Vaccinations and Covid Deaths. These were obtained by dropping columns unrelated to tests, deaths, vaccinations, etc. 

After these two tables were created they were imported into two tables in SQL. The SQL schema for these tables can be found in the Data Exploration folder in the 'Schema.sql' file. After the data was loaded into SQL some exploratory data analysis was performed. These queries can be found under the Data Exploration folder in the 'Queries.sql' file. After I got a general sense of the type of trends and data I wanted to visualize (death rates, vaccination rates and infection rates) I was ready to transfer the data to Tableau. I was using Tableau Public which does not allow you to connect a SQL server to Tableau. So to get around this the query results were transfered to an Excel workbook and those tables were then imported into Tableau. Before transferring the data to Tableau, the queries were refined a bit which can be found under the Data Visualization folder in the 'Queries for Tableau Visualization.sql' file. The results from these queries were place in several sheets in an Excel workbook called 'Tables for Tableau.xlsx'. 

### Data Visualization
