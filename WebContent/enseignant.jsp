<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:if test="${empty isAgent || isAgent}">
	<c:redirect url="/index.jsp?authorize=false"></c:redirect>
</c:if>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Enseignant | Tirage</title>
<link rel="stylesheet" href="./assets/css/bootstrap.min.css">
<link rel="stylesheet" href="./assets/css/bootstrap3-card.css">
<link rel="stylesheet" href="./assets/css/main.css">
<link rel="stylesheet" href="./assets/css/bootstrap-datetimepicker.min.css">
<link rel="stylesheet" href="./assets/css/sweetalert2.min.css"> 
</head>
<body>
	<div class="wrapper">
		<div class="container">
			<div class="row firstrow">
				<div class="col-lg-4" style="margin-top: 5rem;">
					<div class="card hovercard">
		                <div class="cardheader">
		
		                </div>
		                <div class="avatar">
		                    <img alt="" src="./assets/img/avatar.png">
		                </div>
		                <div class="info">
		                    <div class="title">
		                        <h3 id="fullname"></h3>
		                    </div>
		                    <div class="desc">Login : <strong id="login"></strong></div>
		                    <div class="desc">Subjects taught : <strong id="subjects"></strong></div>
		                </div>
		                <div class="bottom">
		                    <form action="Authentication" method="get">
		                    	<button class="btn btn-warning" rel="logout" type="submit">
		                        	<i class="glyphicon glyphicon-remove"></i>
		                    	</button>
		                    </form>
		                    <div class="info">
		                    	<div class="desc">Logout</div>
		                    </div>
		                </div>
            		</div>
				</div>
				<div class="col-lg-8 col-sm-12 col-md-8">
					<form enctype="multipart/form-data" id="formTask">
						<h2 class="text-center">Submit a printing task</h2>
						<div class="form-group">
                			<label>Retrieval date and time</label>
                			<div class='input-group date' id='datepicker'>
                    			<input type='text' class="form-control" name="dateTime"/>
                    			<span class="input-group-addon">
                        		<span class="glyphicon glyphicon-time"></span>
                    			</span>
                			</div>
                			<p class="help-block" id="fromNow">Please select a date and time</p>
            			</div>
						<div class="form-group">
							<label>Subject concerned</label>
							<select class="form-control" id="subjectSelect" name="subjectId">
							</select>
						</div>
						<div class="form-group">
							<label for="copies">Number of copies</label>
							<input type="number" class="form-control" id="copies" value="1" min="1" max="100" name="copies">
						</div>
						<div class="form-group">
						  	<label for="inputFile">Document to print</label>
						  	<input type="file" id="inputFile" name="document" accept="application/pdf,application/msword, 
						  	application/vnd.openxmlformats-officedocument.wordprocessingml.document">
						  	<p class="help-block">*.(pdf/doc/docx) documents are accepted.</p>
						</div>
						<button type="reset" class="btn btn-warning">Reset</button>
  						<button id="submit" type="submit" class="btn btn-default">Submit</button>
					</form>
				</div>
			</div>
			<div class="row secondrow">
				<div class="col-xs-12">
					<h2 class="text-center">My tasks</h2>
					<div class="table-responsive">
						<table class="table table-hover">
							<thead>
								<tr>
									<th>#</th>
									<th>Submission date</th>
									<th>Subject</th>
									<th>Retrieval date</th>
									<th>Copies</th>
									<th>Document</th>
								</tr>
							</thead>
							<tbody id="tasksTable">
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>
	<script type="text/javascript" src="./assets/js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript" src="./assets/js/moment.min.js"></script>
	<script type="text/javascript" src="./assets/js/transition.js"></script>
	<script type="text/javascript" src="./assets/js/collapse.js"></script>
	<script type="text/javascript" src="./assets/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="./assets/js/bootstrap-datetimepicker.min.js"></script>
	<script type="text/javascript" src="./assets/js/sweetalert2.all.min.js"></script>
	<script type="text/javascript" isAgent_tirage="${sessionScope.isAgent}"
		id_tirage="${sessionScope.id}" token_tirage="${sessionScope.token}">
		
		var id_tirage = document.currentScript.getAttribute('id_tirage');
		var token_tirage = document.currentScript.getAttribute('token_tirage');
		var isAgent_tirage = document.currentScript.getAttribute('isAgent_tirage');
		var btn = $('#submit');

		$(document).ready(function() {
			
					
					function populateTasks_tirage(data){
						$.each(data, function(i, task){
							let tr;
							if(task.terminee){
								tr = $('<tr class="success"></tr>');
							}else{
								tr = $('<tr></tr>');
							}
							tr.append($('<th scope="row">'+ (i+1) +'</th>'));
							cr_d = moment(new Date(task.dateCreation)).fromNow();
							tr.append($('<td>'+ cr_d +'</td>'));
							tr.append($('<td>'+ task.matiere.libelle +'</td>'));
							rt_d = moment(new Date(task.dateRecuperation)).format("DD/MM/YYYY HH:mm");
							tr.append($('<td>'+ rt_d +'</td>'));
							tr.append($('<td>'+ task.nbCopies +'</td>'));
							if(task.fileName != null){
								tr.append($('<td><a class="btn btn-success" href="http://localhost:8080/TirageService/api/document/download/'+encodeURI(task.fileName)+'">Download</a></td>)'));
							}else{
								tr.append($('<td><a class="btn btn-secondary" disabled="disabled">Download</a></td>)'));
							}
							$("#tasksTable").append(tr);
						});
					}
			
					function postTask_tirage(idMat, dateRec, copies, filename){
						
						filename = (typeof filename !== 'undefined')? filename : null;
						
						dateRec = moment(dateRec, "DD/MM/YYYY HH:mm").format("YYYY-MM-DDTHH:mm:ss.SSSZ");
						console.log(dateRec);
						
						let task = {
								'dateRecuperation': dateRec,
								'nbCopies': copies,
								'fileName': filename,
						};
						
						$.ajax({
							url: "http://localhost:8080/TirageService/api/taches/enseignant/"+ id_tirage +"/matiere/"+ idMat,
		                    type: "POST",
		                    data: JSON.stringify(task),
		                    dataType: "json",
		                    contentType: "application/json",
		                    beforeSend: function(request) {
		                        request.setRequestHeader("Authorization", token_tirage);
		                    }
						}).done(function(){
							Swal(
									  'Good job!',
									  'The task has been submitted!',
									  'success'
									);
							btn.button('reset');
									
						}).fail(function(){
							Swal({
		                		  type: 'error',
		                		  title: 'Oops...',
		                		  text: 'Failed to submit task!',
		                		});
							btn.button('reset');
						});
					};
					
					$(function () {
						$('#formTask').on("submit", function(e){
							
							btn.button('loading');
							
							let data = new FormData();
							let file = $('#inputFile')[0].files[0];
							
							if(typeof file !== 'undefined'){
								data.append('file',file, file.name);
								$.ajax({
									url: "http://localhost:8080/TirageService/api/document/upload",
									data: data,
									cache: false,
									contentType: false,
									processData: false,
									type:'POST',
									beforeSend: function(request) {
				                        request.setRequestHeader("Authorization", token_tirage);
				                    }
								}).done(function(data){
									
									let serverFileName = data.filename;
									postTask_tirage($('select').val(), $('#datepicker').data().date, $('#copies').val(), serverFileName);
									
								}).fail(function(){
									if(xhr.status == 401){
				                		Swal({
					                		  type: 'error',
					                		  title: 'Oops...',
					                		  text: 'Your session has expired!',
					                		  footer:'<a href="/TirageClient/index.jsp">Sign in again</a>',
					                		  allowOutsideClick: false,
					                		  allowEscapeKey: false,
					                		  showConfirmButton: false
					                		});
				                	}else{
				                		Swal({
					                		  type: 'error',
					                		  title: 'Oops...',
					                		  text: 'File upload failed!',
					                		});
				                	}
								});
							}else{
								postTask_tirage($('select').val(), $('#datepicker').data().date, $('#copies').val());
							}
							return false;
						});
					});
			
					$(function () {
			            	let date = new Date();
			                $('#datepicker').datetimepicker({
			                	minDate: date,
			                	format: 'DD/MM/YYYY HH:mm',
			                	disabledHours: [0, 1, 2, 3, 4, 5, 6, 7, 18, 19, 20, 21, 22, 23, 24],
			                	enabledHours: [8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
			                	daysOfWeekDisabled: [0]
			                }).on('dp.change', function(e) {
			                	$('#fromNow').text(moment(e.date).fromNow());
			                });
			        });
										
		            $.ajax({
		                    url: "http://localhost:8080/TirageService/api/enseignants/" + id_tirage,
		                    type: "GET",
		                    beforeSend: function(request) {
		                        request.setRequestHeader("Authorization", token_tirage);
		                    }
		                }).done(function(data) {
		                	$("#login").text(data.login);
		                	$("#fullname").text(data.nomComplet);
		                	$("#subjects").text(data.matieres.length);
		                	
		                	$.each(data.matieres, function( index, matiere ) {
		                		  $("#subjectSelect").append('<option value="'+ matiere.id +'">'+ matiere.libelle +'</option>');
		                	});
		                	
		                }).fail(function(xhr) {
		                	if(xhr.status == 401){
		                		Swal({
			                		  type: 'error',
			                		  title: 'Oops...',
			                		  text: 'Your session has expired!',
			                		  footer:'<a href="/TirageClient/index.jsp">Sign in again</a>',
			                		  allowOutsideClick: false,
			                		  allowEscapeKey: false,
			                		  showConfirmButton: false
			                		});
		                	}
		                	throw new Error("Session Expired");
		                });
		            
		            $.ajax({
		            	url: "http://localhost:8080/TirageService/api/enseignants/" + id_tirage + "/taches",
		            	type: "GET",
		            	beforeSend: function(request) {
	                        request.setRequestHeader("Authorization", token_tirage);
	                    }
		            }).done(function (data){
		            	
		            	populateTasks_tirage(data);
		            	
		            }).fail(function (xhr){
		            	if(xhr.status == 401){
	                		Swal({
		                		  type: 'error',
		                		  title: 'Oops...',
		                		  text: 'Your session has expired!',
		                		  footer:'<a href="/TirageClient/index.jsp">Sign in again</a>',
		                		  allowOutsideClick: false,
		                		  allowEscapeKey: false,
		                		  showConfirmButton: false
		                		});
	                	}
	                	throw new Error("Session Expired");
		            });

		        });
	</script>
</body>
</html>
