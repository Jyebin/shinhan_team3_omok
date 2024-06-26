<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>오목눈이</title>
    <link rel="stylesheet" href="/css/reset.css"/>
    <link rel="stylesheet" href="/css/common.css"/>
    <link rel="stylesheet" href="/css/signup.css"/>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script src="/js/signup.js"></script>
    <script src="https://code.jquery.com/jquery-latest.min.js"></script>
</head>
<body class="body">
<main class="main">
    <section class="body-item">
        <section class="signup-container">
            <section class="signup-item1">
            </section>
            <section class="signup-item2">
                <div class="signup-item2-container">
                    <div class="signup-item2-div">ID</div>
                    <input class="signup-item2-input id" type="text"> <input class="signup-item2-duple" type="button" value="중복확인"> <input class="hidden" type="hidden" value="false"/>
                </div>
                <div class="signup-item2-container">
                    <div class="signup-item2-div">PW</div>
                    <input class="signup-item2-input pwd1" type="password">
                </div>
                <div class="signup-item2-container">
                    <div class="signup-item2-div">PW</div>
                    <input class="signup-item2-input pwd2" type="password">
                </div>
            </section>
            <section class="signup-item3">
                <input class="regist" type="button" value="회원가입">
                <input class="goback" type="button" value="돌아가기">
            </section>
        </section>
    </section>
</main>
</body>
</html>
