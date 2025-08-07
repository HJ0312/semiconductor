<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>센서 데이터 입력</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f4f6f9;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .container {
            max-width: 600px;
            margin-top: 50px;
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            padding: 30px;
        }
        h2 {
            text-align: center;
            margin-bottom: 30px;
            color: #495057;
            font-weight: 600;
        }
        .form-label {
            font-weight: 500;
            color: #495057;
        }
        .form-control {
            border-radius: 5px;
            border: 1px solid #ced4da;
            transition: border-color 0.3s, box-shadow 0.3s;
        }
        .form-control:focus {
            border-color: #0d6efd;
            box-shadow: 0 0 5px rgba(13, 110, 253, 0.5);
        }
        .btn-submit {
            background: #0d6efd;
            color: #fff;
            border: none;
            border-radius: 5px;
            padding: 10px 20px;
            font-size: 16px;
            font-weight: 500;
            transition: background-color 0.3s, transform 0.2s;
        }
        .btn-submit:hover {
            background: #0a58ca;
            transform: translateY(-2px);
        }
        .btn-submit:active {
            background: #083b87;
            transform: translateY(0);
        }
        .helper-text {
            font-size: 0.9rem;
            color: #6c757d;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>센서 데이터 입력</h2>
        <form action="processInsertSensorData.jsp" method="POST">
            <div class="mb-4">
                <label for="temperature" class="form-label">온도 (℃)</label>
                <input type="number" step="0.1" class="form-control" id="temperature" name="temperature" placeholder="예: 25.5" required>
                <small class="helper-text">온도는 소수점까지 입력 가능합니다.</small>
            </div>
            <div class="mb-4">
                <label for="noise" class="form-label">소음 (dB)</label>
                <input type="number" step="0.1" class="form-control" id="noise" name="noise" placeholder="예: 75.2" required>
                <small class="helper-text">소음은 데시벨 단위로 입력하세요.</small>
            </div>
            <div class="mb-4">
                <label for="gas" class="form-label">가스 농도</label>
                <input type="number" step="0.01" class="form-control" id="gas" name="gas" placeholder="예: 0.85" required>
                <small class="helper-text">가스 농도는 0.01 단위로 입력하세요.</small>
            </div>
            <button type="submit" class="btn btn-submit w-100">데이터 입력</button>
        </form>
    </div>
</body>
</html>
