CREATE DATABASE product;
USE product;
CREATE USER 'product'@'%' IDENTIFIED BY 'password';
GRANT USAGE ON *.* TO 'product'@'%' IDENTIFIED BY 'password';

CREATE TABLE Product (SKU BIGINT NOT NULL AUTO_INCREMENT, DESCRIPTION VARCHAR(255), HEIGHT NUMERIC(8,2) NOT NULL, LENGTH NUMERIC(8,2) NOT NULL, NAME VARCHAR(255), WEIGHT NUMERIC(8,2) NOT NULL, WIDTH NUMERIC(8,2) NOT NULL, FEATURED BOOLEAN, AVAILABILITY INTEGER NOT NULL, IMAGE VARCHAR(255), PRICE NUMERIC(9,2) NOT NULL, PRIMARY KEY (SKU)) AUTO_INCREMENT = 10001;
CREATE TABLE Keyword (Keyword VARCHAR(255) NOT NULL, PRIMARY KEY (Keyword));
CREATE TABLE PRODUCT_KEYWORD (ID BIGINT NOT NULL AUTO_INCREMENT, Keyword VARCHAR(255) NOT NULL, SKU BIGINT NOT NULL, PRIMARY KEY (ID));
ALTER TABLE PRODUCT_KEYWORD ADD INDEX FK_PRODUCT_KEYWORD_Product (SKU), add constraint FK_PRODUCT_KEYWORD_Product FOREIGN KEY (SKU) REFERENCES Product (SKU);
ALTER TABLE PRODUCT_KEYWORD ADD INDEX FK_PRODUCT_KEYWORD_Keyword (Keyword), add constraint FK_PRODUCT_KEYWORD_Keyword FOREIGN KEY (Keyword) REFERENCES Keyword (Keyword);

GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP on product.* to 'product'@'%';


INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('HD LED Picture Quality<p/>ConnectShare Movie<p/>Wide Color Enhancement<p/>Clear Motion Rate 60', 17.5, 29.1, 'ABC HD32CS5002 32-inch LED TV', 17, 3.7, true, 52, 'TV', 249.99 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('HD LED Picture Quality<p/>ConnectShare Movie<p/>Wide Color Enhancement<p/>Clear Motion Rate 60', 22.3, 37.8, 'ABC HD42CS5002 42-inch LED TV', 20.9, 2.2, true, 64, 'TV', 424.95 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('Inverter Technology for even cooking<p/>Inverter Turbo Defrost for quick defrosting<p/>9-Menu Category Sensor Cook system', 12, 22, 'Microtech MM-733N Microwave Oven, 1.6 Cubic Feet', 38.8, 19.5, true, 32, 'Microwave', 178 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('Intel Core i5-4210U 1.7 GHz (3 MB Cache)<p/>4 GB DDR3L SDRAM<p/>0 GB 1 rpm 180 GB Solid-State Drive<p/>14-Inch Screen, Intel HD Graphics 4400<p/>Fedora 21 Operating System', 11.6, 20.4, 'HCM MegaBook 14-Inch Laptop', 6.2, 3.1, true, 213, 'Laptop', 1095.99 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('Finished on all sides for versatile placement<p/>Cinnamon Cherry finish<p/>Cinnamon Cherry', 19.5, 35.2, 'Coffee Table in Cinnamon Cherry Finish', 26.9, 17.1, true, 23, 'CoffeeTable', 44.73 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('HD LED Picture Quality<p/>ConnectShare Movie<p/>Wide Color Enhancement<p/>Clear Motion Rate 60', 33.5, 57.8, 'ABC HD65CS5002 65-inch LED TV', 72.5, 2.8, true, 76, 'TV', 999.00 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('Intel Core i5-4210U 1.7 GHz (3 MB Cache)<p/>4 GB DDR3L SDRAM<p/>0 GB 1 rpm 180 GB Solid-State Drive<p/>15.6-Inch Screen, Intel HD Graphics 4400<p/>Fedora 21 Operating System', 11.9, 21.9, 'HCM MegaBook 15.6-Inch Laptop', 6.9, 3, false, 251, 'Laptop', 1234.32 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('HD LED Picture Quality<p/>ConnectShare Movie<p/>Wide Color Enhancement<p/>Clear Motion Rate 60', 24.7, 42.2, 'ABC HD47CS5002 47-inch LED TV', 28, 2.2, false, 76, 'TV', 529.00 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('HD LED Picture Quality<p/>ConnectShare Movie<p/>Wide Color Enhancement<p/>Clear Motion Rate 60', 28.5, 48.9, 'ABC HD55CS5002 55-inch LED TV', 40.6, 2.2, false, 76, 'TV', 569.00 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('Inverter Technology for even cooking<p/>Inverter Turbo Defrost for quick defrosting<p/>9-Menu Category Sensor Cook system', 14, 24, 'Microtech MM-733N Microwave Oven, 2.2 Cubic Feet', 45.6, 19.5, false, 41, 'Microwave', 135 );
INSERT INTO Product (DESCRIPTION, HEIGHT, LENGTH, NAME, WEIGHT, WIDTH, FEATURED, AVAILABILITY, IMAGE, PRICE) VALUES ('Top lifts up and forward<p/>Hidden storage beneath top<p/>Finished on all sides for versatile placement', 19.4, 41.1, 'Black Finish Coffee Table', 67.6, 19, false, 6, 'CoffeeTable', 142.99 );

INSERT INTO Keyword VALUES('Electronics');
INSERT INTO Keyword VALUES('Furniture');
INSERT INTO Keyword VALUES('TV');
INSERT INTO Keyword VALUES('Microwave');
INSERT INTO Keyword VALUES('Laptop');
INSERT INTO Keyword VALUES('Table');

INSERT INTO PRODUCT_KEYWORD (SKU, Keyword) SELECT SKU, 'Electronics' FROM Product WHERE IMAGE IN ('TV', 'Microwave', 'Laptop');
INSERT INTO PRODUCT_KEYWORD (SKU, Keyword) SELECT SKU, 'Furniture' FROM Product WHERE IMAGE = 'CoffeeTable';
INSERT INTO PRODUCT_KEYWORD (SKU, Keyword) SELECT SKU, 'Microwave' FROM Product WHERE IMAGE = 'Microwave';
INSERT INTO PRODUCT_KEYWORD (SKU, Keyword) SELECT SKU, 'TV' FROM Product WHERE IMAGE = 'TV';
INSERT INTO PRODUCT_KEYWORD (SKU, Keyword) SELECT SKU, 'Laptop' FROM Product WHERE IMAGE = 'Laptop';
INSERT INTO PRODUCT_KEYWORD (SKU, Keyword) SELECT SKU, 'Table' FROM Product WHERE IMAGE = 'CoffeeTable';
