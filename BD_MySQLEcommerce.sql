-- Criação do banco de dados para o e-commerce

CREATE DATABASE ecommerce;
USE ecommerce;


-- Criação das tabelas: Cliente, Produto, Pagamento, Pedido, Estoque, Fornecedor e Vendedor(Terceiro)

CREATE TABLE clients(
	idClient INT AUTO_INCREMENT PRIMARY KEY,
    Fname VARCHAR(10),
    Minit CHAR(3),
    Lname VARCHAR(20),
    CPF CHAR(11) NOT NULL,
    Addres VARCHAR(30),
    BirthDate DATE,
    CONSTRAINT unique_cpf_client UNIQUE(CPF)
);


ALTER TABLE clients AUTO_INCREMENT=1;


CREATE TABLE product(
	idProduct INT AUTO_INCREMENT PRIMARY KEY,
    Pname VARCHAR(10) NOT NULL,
    Category VARCHAR(45) ,
    Price VARCHAR(45),
    productDescription VARCHAR(45)
);

CREATE TABLE payments(
	idPaymentClient INT,
    idPayment INT UNIQUE,
    PaymentType ENUM('Dinheiro','Cartão de Crédito','Cartão de débito',' PIX'),
    LimiteAvailable FLOAT,
    
    PRIMARY KEY (idPaymentClient, idPayment),
    CONSTRAINT fk_payment_client FOREIGN KEY (idPaymentClient) REFERENCES clients(idClient)
);

CREATE TABLE orders(
	idOrder INT AUTO_INCREMENT PRIMARY KEY,
    idOrderClient INT,
    idOrderPayment INT,
    OrderStatus ENUM('Em andamento', 'Processando', 'Enviado', 'Entregue') DEFAULT 'Processando',
    OrderDescription VARCHAR(255),
    sendValue FLOAT DEFAULT 10,
    
    CONSTRAINT fk_orders_payment FOREIGN KEY (idOrderPayment) REFERENCES payments(idPayment),
    CONSTRAINT fk_orders_client FOREIGN KEY (idOrderClient) REFERENCES clients(idClient)
    
			ON UPDATE CASCADE
    );
    
CREATE TABLE productStorage(
	idProdStorage INT AUTO_INCREMENT PRIMARY KEY,
    StorageLocation VARCHAR(255),
    Quantity INT DEFAULT 0
    );
    
CREATE TABLE supplier(
	idSupplier INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(45) NOT NULL,
    CNPJ CHAR(15) NOT NULL,
    Contact CHAR(11) NOT NULL,
    
    CONSTRAINT unique_supplier UNIQUE (CNPJ)
    );
    
CREATE TABLE seller(
	idSeller INT AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(45) NOT NULL,
    CNPJ CHAR(15),
    CPF CHAR(9),
    Contact CHAR(11) NOT NULL,
    Location VARCHAR(255),
    
    CONSTRAINT unique_CNPJ_seller UNIQUE (CNPJ),
	CONSTRAINT unique_CPF_seller UNIQUE (Cpf)
    );
    
CREATE TABLE productSeller(
		idPseller INT,
        idPproduct INT,
        prodQuantity INT DEFAULT 1,
        
        PRIMARY KEY(idPseller,idPproduct),
        CONSTRAINT fk_product_seller FOREIGN KEY(idPSeller) REFERENCES seller(idSeller),
		CONSTRAINT fk_product_product FOREIGN KEY(idPproduct) REFERENCES product(idProduct)
    );
    
CREATE TABLE productOrder(
		idPOproduct INT,
        idPOorder INT,
        poQuantity INT DEFAULT 1,
        poStatus ENUM('Disponível', 'Fora de estoque') DEFAULT 'Disponível',
        
        PRIMARY KEY(idPOproduct,idPOorder),
        CONSTRAINT fk_product_order_order FOREIGN KEY(idPOorder) REFERENCES orders(idOrder),
		CONSTRAINT fk_product_order_product FOREIGN KEY(idPOproduct) REFERENCES product(idProduct)
    );
	
    
CREATE TABLE storageLocation(
		idLproduct INT,
        idLstorage INT,
        Location VARCHAR(255) NOT NULL,
        
        PRIMARY KEY(idLproduct,idLstorage),
        CONSTRAINT fk_storage_location_product FOREIGN KEY(idLproduct) REFERENCES productStorage(idProdStorage),
		CONSTRAINT fk_storage_location_storage FOREIGN KEY(idLproduct) REFERENCES productStorage(idProdStorage)
    );

CREATE TABLE productSupplier(
		idPsSupplier INT,
        idPsProduct INT,
        Quantity INT NOT NULL,
        
        PRIMARY KEY (idPsSupplier, idPsProduct),
        CONSTRAINT fk_product_supplier_supplier FOREIGN KEY (idPsSupplier) REFERENCES supplier(idSupplier),
		CONSTRAINT fk_product_supplier_product FOREIGN KEY (idPsProduct) REFERENCES product(idProduct)
	);


-- -- -- Algumas Queries -- -- --

-- Número total de clientes:
SELECT count(*) FROM clients;

-- Pedidos feitos por esses clientes:
SELECT concat(Fname,' ',Minit, ' ',Lname) as ClientName, Pname, OrderDescription, OrderStatus 
						FROM clients c, orders o, product p 
                        WHERE c.idClient = o.idOrderClient;
 
-- Nome dos clientes e dos produtos(com as suas descrições) que ja foram enviados:
SELECT concat(Fname,' ',Minit, ' ',Lname) as ClientName, Pname, OrderDescription, OrderStatus 
						FROM clients, product, orders 
                        WHERE OrderStatus = 'Enviado';

-- Todos os clientes cadastrados que FIZERAM ALGUM PEDIDO organizados pelo id
SELECT idClient,idOrder, concat(Fname,' ',Lname)as ClientName,Pname , OrderDescription,poStatus
						FROM clients c
                        INNER JOIN orders o ON c.idClient = o.idOrderClient 
						INNER JOIN productOrder p ON p.idPOorder = o.idOrder
                        INNER JOIN product r ON r.idProduct = p.idPOproduct
                        group by idClient;
                        
-- Quantos pedidos cada cliente fez:
SELECT c.idClient, concat(Fname,' ',Lname)as ClientName, count(*)
						FROM clients c
                        INNER JOIN orders o ON c.idClient = o.idOrderClient 
						INNER JOIN productOrder p ON p.idPOorder = o.idOrder
                        group by idClient;
                        

