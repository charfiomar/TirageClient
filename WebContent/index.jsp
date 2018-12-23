<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Home | Tirage</title>
<link rel="stylesheet" href="./assets/css/mustard-ui.min.css">
<link rel="stylesheet" href="./assets/css/main.css">
</head>
<body>
	<div class="row">
		<div class="col-sm-12 col-lg-6" style="margin: 0 auto;">
			<div class="panel">
				<form method="post" action="Authentication">
					<div class="panel-head">
						<h2 class="panel-title">Authentication</h2>
					</div>
					<div class="panel-body">
						<c:if test="${not empty err}">
							<p style="color: #cc0000; font-size: 13px;">${err}</p>
						</c:if>
						<c:if test="${not empty param.authorize}">
							<p style="color: #cc0000; font-size: 10px;">You are not allowed to access this section</p>
						</c:if>
						<div class="form-control">
							<label>Username</label> <input type="text" name="username"
								placeholder="Enter your username" autofocus="autofocus">
						</div>

						<div class="form-control grow-2x">
							<label>Password</label> <input type="password" name="password"
								placeholder="Enter your password">
						</div>
					</div>

					<div class="panel-footer">
						<button class="button-primary" type="submit">Log in</button>
					</div>
				</form>
			</div>
		</div>
	</div>
</body>
</html>