<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:if test="${empty isAgent || not isAgent}">
	<c:redirect url="/index.jsp?authorize=false"></c:redirect>
</c:if>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Agent | Tirage</title>
<link rel="stylesheet" href="./assets/css/bootstrap.min.css">
<link rel="stylesheet" href="./assets/css/bootstrap3-card.css">
<link rel="stylesheet" href="./assets/css/main.css">
<link rel="stylesheet" href="./assets/css/bootstrap-datetimepicker.min.css">
<link rel="stylesheet" href="./assets/css/sweetalert2.min.css"> 
</head>
<body>
	
	<div class="wrapper">
		<div class="container">
			<div class="row">
				<div class="col-xs-4 col-xs-offset-4 text-center">
					<div class="form-group">
                		<label>Retrieval date</label>
                		<div class='input-group date' id='datepicker'>
                    		<input type='text' class="form-control" name="dateTime"/>
                    		<span class="input-group-addon">
                        		<span class="glyphicon glyphicon-time"></span>
                    		</span>
                		</div>
                	</div>
				</div>
				<div class="col-xs-1 col-xs-offset-3">
					<form action="Authentication" method="get">
						<button class="btn btn-warning" type="submit">Logout</button>
					</form>
				</div>
			</div>
			<div class="row firstrow">
				<div class="col-xs-12">
					<h2 class="text-center">Tasks to do</h2>
					<div class="table-responsive">
						<table class="table table-hover">
							<thead>
								<tr>
									<th>#</th>
									<th>Submission date</th>
									<th>Owner</th>
									<th>Subject</th>
									<th>Retrieval time</th>
									<th>Copies</th>
									<th>Document</th>
									<th>Action</th>
								</tr>
							</thead>
							<tbody id="tasksTable">
								<tr>
									<td class="text-center" colspan="8">Nothing to do</td>
								</tr>
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
		var tasks;
		
		function validate(taskId){
			Swal({
				  title: 'Are you sure?',
				  text: "You won't be able to revert this!",
				  type: 'warning',
				  showCancelButton: true,
				  confirmButtonColor: '#3085d6',
				  cancelButtonColor: '#d33',
				  confirmButtonText: 'Yes, validate it!'
				}).then((result) => {
				  if (result.value) {
				    
					  t = tasks.filter(task => {
						 return task.id == taskId;
					  })[0];
					  
					  
					  tData = {
							  
							  dateCreation: moment(t.dateCreation).format("YYYY-MM-DDTHH:mm:ss.SSSZ"),
							  dateRecuperation: moment(t.dateRecuperation).format("YYYY-MM-DDTHH:mm:ss.SSSZ"),
							  fileName: t.fileName,
							  nbCopies: t.nbCopies,
							  terminee: true,
					  }
					  
					  $.ajax({
						  url: 'http://localhost:8080/TirageService/api/taches/' + taskId + '/enseignant/' + t.enseignant.id + '/matiere/' + t.matiere.id,
						  type: 'PUT',
						  data: JSON.stringify(tData),
		                  dataType: "json",
		                  contentType: "application/json",
		                  beforeSend: function(request) {
		                	  request.setRequestHeader("Authorization", token_tirage);
		                  },
					  }).done(function(){
						  Swal(
							      'Validated!',
							      'Your task has been validated',
							      'success'
							    )
						  $("#task-"+taskId).addClass('success');
						  $("#val-"+taskId).removeClass('btn-success');
						  $("#val-"+taskId).addClass('btn-secondary');
						  $("#val-"+taskId).prop("onclick", null).off("click");
						  $("#val-"+taskId).attr( "disabled", "disabled" );;
					  }).fail(function() {
						  Swal({
	                		  type: 'error',
	                		  title: 'Oops...',
	                		  text: 'Failed to validate Task!',
	                		});
					  });
				  }
				})
		};
		
		$(document).ready(function(){
			
			$(function () {
                $('#datepicker').datetimepicker({
                	format: 'DD/MM/YYYY',
                	daysOfWeekDisabled: [0]
                }).on('dp.change', function() {
                	populate_tasks($('#datepicker').data().date);
                });
        	});
			
			function populate_tasks(date){
				filtered = tasks.filter(function (task) {
					return moment(task.dateRecuperation).format("DD/MM/YYYY") == date;
				});
				$("#tasksTable").empty();
				if(filtered.length == 0){
					$("#tasksTable").append('<tr><td class="text-center" colspan="8">Nothing to do</td></tr>');
				}else {
					$.each(filtered, function(i, task){
						let tr;
						if(task.terminee){
							tr = $('<tr class="success" id="task-'+task.id+'"></tr>');
						}else{
							tr = $('<tr id="task-'+task.id+'"></tr>');
						}
						tr.append($('<th scope="row">'+ (i+1) +'</th>'));
						cr_d = moment(new Date(task.dateCreation)).fromNow();
						tr.append($('<td>'+ cr_d +'</td>'));
						tr.append($('<td>'+ task.enseignant.nomComplet +'</td>'));
						tr.append($('<td>'+ task.matiere.libelle +'</td>'));
						rt_d = moment(new Date(task.dateRecuperation)).format("HH:mm");
						tr.append($('<td>'+ rt_d +'</td>'));
						tr.append($('<td>'+ task.nbCopies +'</td>'));
						if(task.fileName != null){
							tr.append($('<td><a class="btn btn-success" href="http://localhost:8080/TirageService/api/document/download/'+encodeURI(task.fileName)+'">Download</a></td>)'));
						}else{
							tr.append($('<td><a class="btn btn-secondary" disabled="disabled">Download</a></td>)'));
						}
						if(task.terminee){
							tr.append($('<td><a class="btn btn-secondary" disabled="disabled">Validate</a></td>'));
						}else{
							tr.append($('<td><a class="btn btn-success" id="val-'+task.id+'" onclick=validate('+task.id+')>Validate</a></td>'));
						}
						$("#tasksTable").append(tr);
					});
				}
			};
			
			function getTasks(){
				let t;
				
				$.ajax({
					url:'http://localhost:8080/TirageService/api/taches',
					type:'GET',
					async: false,
					beforeSend: function(request) {
                        request.setRequestHeader("Authorization", token_tirage);
                    }
				}).done(function(data) {
					t = data;
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
				});
				return t;
			};
			
			setTimeout(function () {
				tasks = getTasks();
				populate_tasks($('#datepicker').data().date);
			}, 500);
			
		});
		
	</script>
</body>
</html>
