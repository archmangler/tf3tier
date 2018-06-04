#!/bin/bash
#Install NGINX,PHP+FPM,GIT
sudo apt-get update
sudo apt-get install -y nginx git php-fpm php-mysql

# Add nginx test configuration
sudo cat >/etc/nginx/sites-available/default << "EOF"
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm index.nginx-debian.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Add db connect file to connect to db server
sudo cat >/var/www/html/db_connect.php << "EOF"
<?php
   define('DB_DSN', 'mysql:host=192.168.2.21;dbname=crud;charset=utf8');
   define('DB_USER', 'root');
   define('DB_PASS', 'J4BB3rW0cky##');
   try {
       $db = new PDO(DB_DSN, DB_USER, DB_PASS);
   } catch (PDOException $e) {
       echo 'Error: '.$e->getMessage();
       die(); // Force execution to stop on errors.
  }
?>
EOF

# Add CRUD code as index.php
sudo cat >/var/www/html/index.php << "EOF"
<?php 
    require('db_connect.php');
    if ($_POST) { // If request is a POST, perform CREATE, UPDATE OR DELETE Actions.
        // Sanitize the POSTed quote to guard for HTML, CSS and Javascript injection.
        $quote = filter_input(INPUT_POST, 'quote', FILTER_SANITIZE_FULL_SPECIAL_CHARS);
        if (isset($_POST['create'])) {          // C is for CREATE
            
            $create = $db->prepare("INSERT INTO quotes (content) VALUES (:quote)");
            $create->bindValue(':quote', $quote);
            $create->execute();
        } elseif (isset($_POST['update'])       // U is for UPDATE
                  && isset($_POST['id'])) {     // Primary key id required.
            
            $update = $db->prepare("UPDATE quotes SET content = :quote WHERE id = :id");
            $update->bindValue(':quote', $quote);
            $update->bindValue(':id', $_POST['id'], PDO::PARAM_INT); // Sanitize bound id as an integer.
            $update->execute();
        } elseif (isset($_POST['delete'])       // D is for DELETE
                  && isset($_POST['id'])) {     // Primary key id required.
            
            $delete = $db->prepare("DELETE FROM quotes WHERE id = :id LIMIT 1");
            $delete->bindValue(':id', $_POST['id'], PDO::PARAM_INT);  // Sanitize bound id as an integer.
            $delete->execute();
        } // EndIfElse: CREATE, UPDATE and DELETE action.
        
    } // EndIf: POST Processing and DB Actions
    
    // R is for READ.
    // Executed every time, unlike CUD actions above which trigger on POST.
    $select = $db->prepare("SELECT * FROM quotes"); 
    $select->execute(); 
?>
<!doctype html>
<html>
<head>
    <title>TinyCRUD</title>
    <meta charset="utf-8">
    <!-- CSS for input widths and form margin. Visual tweaks unessential to the CRUD. -->
    <style>input{width: 400px} input[type="submit"]{width: 60px} form{margin-bottom: 5px}</style>
</head>
<body>

    <!-- Loop through all rows selected in the R is for READ action. -->
    <?php while($row = $select->fetch()): ?>

        <!-- One form per quote used for display, update and delete. -->
        <form method="post">
            <!-- Hidden input for the primary key id of each quote. -->
            <input type="hidden" name="id" value="<?= $row['id'] ?>">

            <!-- Display the quote as the value of a text input. -->
            <input value="<?= $row['content'] ?>" name="quote">

            <!-- *Two* submit inputs! Triggers for UPDATE & DELETE actions. -->
            <input name="update" type="submit" value="update">
            <input name="delete" type="submit" value="delete">
        </form>

    <?php endwhile ?>

    <!-- One last form for CREATE quote action in above code. -->
    <form method="post">
        <input name="quote">
        <input name="create" type="submit" value="create">
    </form>
</body>
</html>
EOF

#Restart nginx
sudo systemctl restart nginx
