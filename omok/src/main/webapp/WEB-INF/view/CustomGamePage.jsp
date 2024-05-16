<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>오목눈이</title>

    <link rel="stylesheet" href="/css/reset.css"/>
    <link rel="stylesheet" href="/css/common.css"/>
    <link rel="stylesheet" href="/css/game.css"/>
    <link rel="stylesheet" href="/css/clock.css"/>
    <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery/1.10.1/jquery.min.js"></script>
    <script src="http://cdnjs.cloudflare.com/ajax/libs/moment.js/2.0.0/moment.min.js"></script>
    <script src="/clock.js"></script>
    <script>
        // 변수 초기화
        var type="<%=session.getAttribute("type") %>";
        var room="<%=session.getAttribute("room")%>";
        var name="<%=session.getAttribute("name")%>";

        var webSocket;
        var currentUser;
        var myStoneColor, enemyStoneColor;

        if (type == "create") {
            currentUser = "O";
            myStoneColor = "black";
            enemyStoneColor = "white";
        } else {
            currentUser = "X";
            myStoneColor = "white";
            enemyStoneColor = "black";
        }

        function setStoneColor(stoneColor, elementId) {
            document.querySelector(elementId).src = '/img/' + stoneColor + 'dot.png';
        }

        function appendChatMessage(obj, type) {
            let chatmain = document.querySelector("#chatmain");
            if (obj.type == type) {
                chatmain.insertAdjacentHTML('beforeend', "<div class='chatmain-right-container'><div class='chatmain-right'>" + obj.message + "</div></div>");
            } else {
                chatmain.insertAdjacentHTML('beforeend', '<div class="chatmain-left-container"><div class="chatmain-left">' + obj.message + '</div></div>');
            }
            let scroll = document.querySelector("#chatmain");
            scroll.scrollTop = scroll.scrollHeight;
        }

        function sendMessage(obj) {
            webSocket.send(JSON.stringify(obj));
        }

        function placeStone(x, y, stoneColor) {
            const go = document.getElementById('go');

            // 바둑알 이미지 가져오기
            const stone = document.createElement('img');
            stone.src = '/img/' + stoneColor + 'dot.png';
            stone.className = 'stone';

            stone.style.left = '0px';
            stone.style.right = '0px';
            stone.style.width = '53px';
            stone.style.height = '53px';

            // 클릭한 곳이 바둑알의 중심 좌표가 되게
            var stoneX = (x * 53 + 34) - (stone.width / 2);
            var stoneY = (y * 53 + 34) - (stone.height / 2);

            // css 속성으로 바둑알 위치 지정
            stone.style.position = 'absolute';
            stone.style.left = stoneX + 'px';
            stone.style.top = stoneY + 'px';
            stone.style.zIndex = '6';

            go.appendChild(stone);
        }
    </script>
    <script>
        window.onload = function () {
            webSocket = new WebSocket("ws://localhost:9090/" + room + "/" + type);
            $(".opponent2").hide();

            // 캐릭터 머리 위 바둑알 색 설정
            setStoneColor(myStoneColor, "#myStone");
            setStoneColor(enemyStoneColor, "#enemyStone");

            let msgbutton = document.querySelector("#msgbutton");
            let msgtext = document.querySelector("#msgtext");

            webSocket.onopen = function (e) { // websocket 서버가 열리면 실행 되는 함수
                appendChatMessage({message: "방에 입장 하였습니다.", type}, type);
                sendMessage({enemyName: name, event: "naming"});
            };

            webSocket.onmessage = function (e) { // WebSocket 서버로 부터 메시지가 오면 호출되는 함수
                let obj = JSON.parse(e.data); // 받은 데이터 파싱
                if (obj.event == "chat") { // 채팅
                    appendChatMessage(obj, type);
                } else if (obj.event == "omok") { // 오목 돌 두기
                    currentUser = "O"; // 데이터를 받았으니 사용자로 턴 돌아옴
                    var x2 = obj.x;
                    var y2 = obj.y;

                    if (x2 < 0 || y2 < 0 || y2 > 12 || x2 > 12) {
                        return;
                    }
                    placeStone(x2, y2, enemyStoneColor);

                    // 이김 여부 판별
                    if (obj.state == "win") {
                        // 이겼을 때 로직
                    } else if (obj.state == "lose") {
                        // 졌을 때 로직
                    }
                } else if (obj.event == 'naming') { // 상대방 이름 설정
                    document.getElementById("enemy").append(obj.enemyName);
                    // 상대방 캐릭터 띄우고, 코드박스 사라지게
                    $("#codeBox").hide();
                    $(".opponent2").show();
                } else if (obj.event == 'state') {
                    webSocket.close();
                    window.location.replace("/main");
                }
            };

            msgbutton.addEventListener('click', function () { // 전송 버튼 이벤트
                sendMessage({message: msgtext.value, event: 'chat'});
                document.querySelector("#msgtext").value = '';
            })
        };
    </script>
    <script>
        // 바둑알 놓기
        document.addEventListener('DOMContentLoaded', function () {
            const board = document.getElementById('checkerboard-img');
            const go = document.getElementById('go');

            board.addEventListener('click', function (event) {
                if (currentUser == 'X') {
                    alert("순서가 아닙니다.");
                } else {
                    // 이미지 내에서의 좌표를 구하기 위해 offset 사용
                    const rect = board.getBoundingClientRect();

                    // 클릭한 곳으로부터 가장 가까운 점에 바둑알 놓이게 + 반환될 x, y 좌표 계산 (0~12범위)
                    var x = Math.round((Math.round(event.clientX - rect.left - 34) / 53));
                    var y = Math.round((Math.round(event.clientY - rect.top - 34) / 53));

                    if (x < 0 || y < 0 || y > 12 || x > 12) {
                        return;
                    }

                    placeStone(x, y, myStoneColor);
                    sendMessage({x: x, y: y, state: 'continue', event: 'omok'});

                    currentUser = "X";
                }
            });

            var exit = document.getElementById("exit");
            exit.addEventListener('click', function (event) {
                webSocket.close();
            });
        });
    </script>
    <script>
        function copy() {
            var roomCode = document.getElementById('roomCode2'); //id가 roomCode인 값을 가져와 roomCode에 대입
            var range = document.createRange(); //복사할 텍스트의 범위 지정
            range.selectNode(roomCode); //roomCode 요소의 내용 선택
            //window.getSelection().removeAllRanges(); //범위 제거
            window.getSelection().addRange(range); //위에서 만든 range를 현재 선택에 추가
            document.execCommand('copy'); //클립보드에 복사
            alert('방 코드가 복사되었습니다.');
        }

        function change() {
            const roomCode = document.getElementById('roomCode2').innerText;
            const xml = new XMLHttpRequest(); //XMLHttpRequest 객체 생성(서버 통신을 위함)
            xml.open('POST', '/custom-game'); //서버로 요청을 보냄
            xml.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
            const requestBody = "roomCode="+encodeURIComponent(roomCode); //요청 본문에 roomCode 값 추가
            xml.onreadystatechange = function () { //서버로부터 응답이 도착할 때마다 호출
                if (xml.readyState === XMLHttpRequest.DONE) { //서버와의 통신이 완료되면
                    alert('공개 방으로 전환합니다.');
                    window.location.href = '/random-game';
                }
            };
            xml.send(requestBody);
        }
    </script>
</head>

<body class="body">
<main class="main">
    <section class="body-item">
        <section class="body-container">
            <section class="body-container-left">
                <div id="go">
                    <img src="/img/checkerboard.png" id="checkerboard-img">
                </div>
            </section>

            <aside class="body-container-right">
                <div id="clock" class="light">
                    <div class="display">
                        <div class="digits"></div>
                    </div>
                </div>

                <div class="opponents">
                    <div class="opponent">
                        <img class="opponents-dot" id="myStone"/>
                        <img class="opponents-img" src="/img/right_character.png">
                        <div class="opponents-id"><img class="me" src="/img/mestar.png">${name}</div>
                    </div>
                    <div class="opponent opponent2">
                        <img class="opponents-dot" id="enemyStone"/>
                        <img class="opponents-img" src="/img/left_character.png">
                        <div class="opponents-id" id="enemy"></div>
                    </div>
                    <div class="codeBox" id="codeBox">
                        <div class="codeBox-title">참여자 대기중</div>
                        <div class="codeBox-code" id="roomCode">
                            <p id="roomCode2">${roomCode}</p>
                        </div>
                        <div class="codeBox-buttons">
                            <input type="button" onclick="copy()" class="codeBox-buttons-copy" value="코드복사"/>
                            <input type="button" onclick="change()" class="codeBox-buttons-convert" value="공개방 전환"/>
                        </div>
                    </div>
                </div>


                <div class="chat">
                    <div class="chatheader"></div>
                    <div id="chatmain" class="chatmain"></div>
                    <div class="chatfooter">
                        <div class="chatfooter-inner">
                            <input id="msgtext" type="text"/><input type="button" id="msgbutton" value="전송">
                        </div>
                    </div>
                </div>
                <div class="exit-container">
                    <form action="/main" method="get">
                        <input type="submit" class="exit" id="exit" value="게임 나가기"/>
                    </form>
                </div>
            </aside>
        </section>
    </section>
</main>
</body>

</html>