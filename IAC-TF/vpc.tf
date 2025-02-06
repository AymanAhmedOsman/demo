provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}



resource "aws_vpc" "Demo" {    

    cidr_block =  "10.0.0.0/16"
    enable_dns_support = true

    tags = {
      name = "Demo"
    }
  
}
# ===========================================Subnet===============================


#------------------------------------ public subnet ----------------------------------
resource "aws_subnet" "public_1" {

    vpc_id = aws_vpc.Demo.id
    availability_zone = "us-east-1a"
    cidr_block =  "10.0.0.0/24"

    tags = {
      name = "public_subnet"
    }
    
 
}

resource "aws_subnet" "public_2" {

    vpc_id = aws_vpc.Demo.id
    availability_zone = "us-east-1b"
    cidr_block =  "10.0.3.0/24"

    tags = {
      name = "public_subnet"
    }
    
    
}




#---------------------------------- private Subnet ----------------------------------


resource "aws_subnet" "private_1" {
    vpc_id = aws_vpc.Demo.id
    availability_zone = "us-east-1a"
    cidr_block =  "10.0.1.0/24"
    
    tags = {
      name = "private_subnet1"
    }
    
 
}

resource "aws_subnet" "private_2" {
    vpc_id = aws_vpc.Demo.id
    availability_zone = "us-east-1b"
    cidr_block =  "10.0.2.0/24" 

    tags = {
      name = "private_subnet2"
    }
 
}





#-------------------------------subnet group --------------------------

resource "aws_db_subnet_group" "demo_db-sngrp" {
  name = "mydb-sngrp"
  subnet_ids = [ aws_subnet.private_2.id, aws_subnet.private_1.id ]
  
}




############################### IG ################################
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.Demo.id

    tags = {
        Name = "gw"
  }

  
}

############################### NAT ################################
resource "aws_eip" "nat_ip" {

    tags = {
    Name = "nat_ip"
  }
}
resource "aws_nat_gateway" "natdemo" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public_2.id
    tags = {
    Name = "natdemo"
  }
}



############################### public rout table ################################

resource "aws_route_table" "rout_public" {
    vpc_id = aws_vpc.Demo.id

    
    tags = {
        Name = "Demo_rt"
    }

}
resource "aws_route" "public" {
      
        route_table_id = aws_route_table.rout_public.id
        destination_cidr_block ="0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
     

}


resource "aws_route_table_association" "public_association1" {
    subnet_id = aws_subnet.public_1.id
    route_table_id = aws_route_table.rout_public.id
  
}

resource "aws_route_table_association" "public_association2" {
    subnet_id = aws_subnet.public_2.id
    route_table_id = aws_route_table.rout_public.id
  
}
############################### private rout table ################################

resource "aws_route_table" "rout_private" {
    vpc_id = aws_vpc.Demo.id

    
    tags = {
        Name = "Demo_rt"
    }

}
resource "aws_route" "private" {
      
        route_table_id = aws_route_table.rout_private.id
        destination_cidr_block ="0.0.0.0/0"
        # gateway_id = aws_nat_gateway.g2.id
        gateway_id = aws_nat_gateway.natdemo.id
     

}


resource "aws_route_table_association" "private_association3" {
    subnet_id = aws_subnet.private_1.id
    route_table_id = aws_route_table.rout_private.id
  
}
resource "aws_route_table_association" "private_association4" {
    subnet_id = aws_subnet.private_2.id
    route_table_id = aws_route_table.rout_private.id
  
}

