var firstsearch = true;
var search_count = 0;
$(function(){

	$(".searchbox").click(function(){
		if (!firstsearch && $(this).children(".comment_block").css("display") == "none"){
			$(".searchbox").removeClass("area_select");
			$(this).addClass("area_select");
			closediv();
			$(this).children(".comment_block").slideDown();
			$("#"+$(this).children(".target_itemlist_frame").attr("value")).slideDown();
		}
	})

	$("#allsearch").click(function(){
		if (firstsearch){
			$(".itemlist").html("<p>検索中</p>");
			firstsearch = false;
			changeviewonfirstsearch();
		}
		amazonsearch ($("#searchtext1").val(),"#itemlist1","","amazon");
		amazonsearch ($("#searchtext2").val(),"#itemlist2","","amazon");
		amazonsearch ($("#searchtext3").val(),"#itemlist3","","amazon");
		amazonsearch ($("#searchtext4").val(),"#itemlist4","","amazon");
		amazonsearch ($("#searchtext5").val(),"#itemlist5","","amazon");
		amazonsearch ($("#searchtext6").val(),"#itemlist6","","amazon");
		amazonsearch ($("#searchtext7").val(),"#itemlist7","","amazon");
		amazonsearch ($("#searchtext8").val(),"#itemlist8","","amazon");
		amazonsearch ($("#searchtext9").val(),"#itemlist9","","amazon");
		amazonsearch ($("#searchtext10").val(),"#itemlist10","","amazon");
	})

	$(".re_search").click(function(){
		switch( $(this).get(0).id ) {
			case "re_search1": amazonsearch ($("#searchtext1").val(),"#itemlist1","","amazon"); break;
			case "re_search2": amazonsearch ($("#searchtext2").val(),"#itemlist2","","amazon"); break;
			case "re_search3": amazonsearch ($("#searchtext3").val(),"#itemlist3","","amazon"); break;
			case "re_search4": amazonsearch ($("#searchtext4").val(),"#itemlist4","","amazon"); break;
			case "re_search5": amazonsearch ($("#searchtext5").val(),"#itemlist5","","amazon"); break;
			case "re_search6": amazonsearch ($("#searchtext6").val(),"#itemlist6","","amazon"); break;
			case "re_search7": amazonsearch ($("#searchtext7").val(),"#itemlist7","","amazon"); break;
			case "re_search8": amazonsearch ($("#searchtext8").val(),"#itemlist8","","amazon"); break;
			case "re_search9": amazonsearch ($("#searchtext9").val(),"#itemlist9","","amazon"); break;
			case "re_search10": amazonsearch ($("#searchtext10").val(),"#itemlist10","","amazon"); break;
		}
	})

	$("#register").click(function(){
		regist();
	})

	$(".searchbox").hover(function(){
		if (!firstsearch){
			$(this).addClass("area_hover");
		}
	},function(){
		if (!firstsearch){
			$(this).removeClass("area_hover");
		}
	})

	$(".toggleval").toggleVal({
		focusClass: "hasFocus",
		changedClass: "isChanged"
	})

	$(".comment_button").click(function(){
		comment($(this).parent().get(0).id, $(this).parent().children("#userid").attr('value'), $(this).parent().children("#asin").attr('value'), $(this).parent().children("#comment").val());
	})

	$(".comment_view").click(function(){
		$(this).parent().next().slideDown();
		$(this).parent().hide();
	})

	$(".good_button").click(function(){
		good($(this).parent().get(0).id, $(this).children("#userid").attr('value'), $(this).children("#asin").attr('value'));
	})

	$(".good_number").click(function(){
		$(this).parent().next().show();
		$(this).parent().hide();
	})

	$(".favorite_button").click(function(){
		favorite($(this).children("#userid").attr('value'));
	})

	$(".unfavorite_button").click(function(){
		unfavorite($(this).children("#userid").attr('value'));
	})

	$('.blogparts_script')
		.click(function(){
			$(this).select();
			return false;
	});

	$("#goodget_add_button").click(function(){
		goodget_add( $('#userid').attr('value'), Number($('#goodget_page').attr('value')) , Number($('#goodget_count').attr('value')) , "goodget_page");
	})
	$("#goodgive_add_button").click(function(){
		goodgive_add( $('#userid').attr('value'), Number($('#goodgive_page').attr('value')) , Number($('#goodgive_count').attr('value')) , "goodgive_page");
	})
	$("#resget_add_button").click(function(){
		resget_add( $('#userid').attr('value'), Number($('#resget_page').attr('value')) , Number($('#resget_count').attr('value')) , "resget_page");
	})
	$("#resgive_add_button").click(function(){
		resgive_add( $('#userid').attr('value'), Number($('#resgive_page').attr('value')) , Number($('#resgive_count').attr('value')) , "resgive_page");
	})

	var option={ 
		items : '.searchbox', 
		update : function(){
			var num=1;
			$('.searchbox','#sortList').attr('id',function(i){

				var target = $('#'+this.id).children(".target_itemlist_frame").attr("value");
				$('#'+target).parent().children('.target_searchbox').attr('value','searchbox'+num);
				$('#'+target).children('.loader_head').attr('id','loader_head'+num);
				$('#'+target).children('.itemlist').attr('id','itemlist'+num);
				$('#'+target).children('.loader_foot').attr('id','loader_foot'+num);
				$('#'+target).attr('id','temp_itemlist_frame'+num);

				$('#'+this.id).children('.target_itemlist_frame').attr('value','temp_itemlist_frame'+num);
				$('#'+this.id).children('.searchbox_searcharea').children('.searchasin').attr('id','searchasin'+num);
				$('#'+this.id).children('.searchbox_searcharea').children('.rank_value').html(num+'位：');
				$('#'+this.id).children('.searchbox_searcharea').children('.searchtext').attr('id','searchtext'+num);
				$('#'+this.id).children('.searchbox_searcharea').children('.re_search').attr('id','re_search'+num);
				$('#'+this.id).children('.searchbox_image').attr('id','searchbox_image'+num);
				$('#'+this.id).children('.comment_block').attr('id','comment_block'+num);
				$('#'+this.id).children('.comment_block').children('.commentarea').attr('id','comment'+num);
				$('#'+this.id).attr('id','temp_searchbox'+num);
				num += 1;
			});
			num=1;
			$('.searchbox','#sortList').attr('id',function(i){
				var target = $('#'+this.id).children(".target_itemlist_frame").attr("value");
				$('#'+target).attr('id','itemlist_frame'+num);
				$('#'+this.id).children('.target_itemlist_frame').attr('value','itemlist_frame'+num);

				$('#'+this.id).attr('id','searchbox'+num);
				num += 1;
			});
		}
	};
	$('#sortList').sortable(option);

})

function changeviewonfirstsearch() {
	$(".searchbox_searcharea").css({ float:"left" });
	$(".re_search").css({ display:"inline" });
	$(".searchbox_image").fadeIn();
	$("#searchbox1").trigger('click');
}

function amazonsearch (keyword,target,page,template) {
	if ( search_count == 0 ) {
		$('#sortList').sortable('disable');
	}
	search_count += 1;

	pager = true;
	if (!page) {
		page = 1;
		pager = false;
	}

	$(target).parent().children(".loader").slideDown();
	$.ajax({
		dataType: "text",
		data: { 
			"keyword": keyword,
			"page": page,
		},
		type: "POST",
		url:"http://bestgameon.net/search/"+template,
		timeout: 300000,
		success: function (data) { 
			$(target).hide();
			$(target).html(data);
			$(target).slideDown();
			if ( !pager ) {
				$(target).children("#firstitem").children(".item_click").trigger('click');
			}
		},
		error: function (data,status,errorThrown){
			$(target).html("Request Timeout.");
		},
		complete: function (XMLHttpRequest, textStatus){
			$(target).parent().children(".loader").hide();
			search_count -= 1;
			if ( search_count == 0 ) {
				$('#sortList').sortable('enable');
			}
		}
	});
}

function itemselect (target,gameasin,gametitle,gameimagehtml) {
		$("#"+target).children(".searchbox_searcharea").children(".searchtext").val(gametitle);
		$("#"+target).children(".searchbox_searcharea").children(".searchasin").attr("value",gameasin);
		if (gameimagehtml == '') {
			gameimagehtml = "<img src=\"http://g-ec2.images-amazon.com/images/G/09/x-site/icons/no-img-sm.gif\" alt=\""+gametitle+"\" />";
		} else {
			gameimagehtml = "<img src=\""+gameimagehtml+"\" alt=\""+gametitle+"\" />";
		}
		$("#"+target).children(".searchbox_image").html(gameimagehtml);
}

function regist () {

	$("#regist_wait").show();

	var comment1 = $("#comment1").val();
	var comment2 = $("#comment2").val();
	var comment3 = $("#comment3").val();
	var comment4 = $("#comment4").val();
	var comment5 = $("#comment5").val();
	var comment6 = $("#comment6").val();
	var comment7 = $("#comment7").val();
	var comment8 = $("#comment8").val();
	var comment9 = $("#comment9").val();
	var comment10 = $("#comment10").val();

	var defText= "コメントを書いてください（任意）";

	if ( comment1 == defText ) { comment1 = "";}
	if ( comment2 == defText ) { comment2 = "";}
	if ( comment3 == defText ) { comment3 = "";}
	if ( comment4 == defText ) { comment4 = "";}
	if ( comment5 == defText ) { comment5 = "";}
	if ( comment6 == defText ) { comment6 = "";}
	if ( comment7 == defText ) { comment7 = "";}
	if ( comment8 == defText ) { comment8 = "";}
	if ( comment9 == defText ) { comment9 = "";}
	if ( comment10 == defText ) { comment10 = "";}

	$.ajax({
		dataType: "json",
		data: { 
			"rank1": $("#searchasin1").attr("value"),
			"rank2": $("#searchasin2").attr("value"),
			"rank3": $("#searchasin3").attr("value"),
			"rank4": $("#searchasin4").attr("value"),
			"rank5": $("#searchasin5").attr("value"),
			"rank6": $("#searchasin6").attr("value"),
			"rank7": $("#searchasin7").attr("value"),
			"rank8": $("#searchasin8").attr("value"),
			"rank9": $("#searchasin9").attr("value"),
			"rank10": $("#searchasin10").attr("value"),
			"comment1":comment1 ,
			"comment2":comment2 ,
			"comment3":comment3 ,
			"comment4":comment4 ,
			"comment5":comment5 ,
			"comment6":comment6 ,
			"comment7":comment7 ,
			"comment8":comment8 ,
			"comment9":comment9 ,
			"comment10":comment10,
			"draft":$("#draft").is(":checked"),
		},
		type: "POST",
		url: "http://bestgameon.net/regist/",
		timeout: 300000,
		success: function (data) { 
			if(data.error_flag){
				$("#regist_wait").hide();
				var messages = "";
				for (var i in data.messages){
					messages += data.messages[i]+"\n";
				}
				alert (messages);
			} else {
				$("#regist_wait").hide();
				location.href = "http://bestgameon.net/mypage";
			}
		},
		error: function (data,status,errorThrown){
			alert (status+"エラーが発生しました。もう一度登録をお試しください。");
		},
	});
}

function reload_loginbox () {
	$.ajax({
		type: "GET",
		url: "http://bestgameon.net/loginbox/",
		timeout: 60000,
		success: function (data) { 
			$("#loginbox").html(data);
		},
		error: function (data,status,errorThrown){
			$("#loginbox").html(data);
		},
	});
}

function closediv () {
	$(".comment_block").slideUp();
	$(".itemlist_frame").hide();
}

function comment( target, to_userid, asin, comment ) {

	var jsondata;

	$("#"+target).children(".comment_loading").show();
	$("#"+target).children(".comment_error").html("");

	$.ajax({
		dataType: "json",
		data: { 
			"to_userid": to_userid,
			"asin": asin,
			"comment": comment,
		},
		type: "POST",
		url:"http://bestgameon.net/comment/",
		timeout: 300000,
		success: function (data) { 
			jsondata = data;
		},
		error: function (data,status,errorThrown){
			jsondata = data;
		},
		complete: function (XMLHttpRequest, textStatus){
			$("#"+target).children(".comment_loading").hide();
			if(!jsondata.error_flag){
				comment = comment.replace(/\r\n/g, "<br />");
				comment = comment.replace(/(\n|\r)/g, "<br />");
				var newcomment = $("#"+target).children(".comment_add_area").html()+"<div class=\"comment_item\"><div class=\"user_comment_container\"><div class=\"user_comment\"><p><a href=\"http://bestgameon.net/rank/"+jsondata.to_username+"\" >"+jsondata.to_username+"</a><br/>"+comment+"</p></div></div><a href=\"http://bestgameon.net/rank/"+jsondata.to_username+"\" class=\"user_icon\"><img src=\"http://img.tweetimag.es/i/"+jsondata.to_username+"_m\" alt=\""+jsondata.to_username+"\" /></a></div>";
				$("#"+target).children(".comment_add_area").html( newcomment );
				$("#"+target).children("#comment").val("");
			} else {
				$("#"+target).children(".comment_error").html( jsondata.error_message );
			}
		},
	});
}

function good( target, to_userid, asin ) {

	var jsondata;

	$("#"+target).children(".good_loading").show();

	$.ajax({
		dataType: "json",
		data: { 
			"to_userid": to_userid,
			"asin": asin,
		},
		type: "POST",
		url:"http://bestgameon.net/good/",
		timeout: 300000,
		success: function (data) { 
			jsondata = data;
		},
		error: function (data,status,errorThrown){
			jsondata = data;
		},
		complete: function (XMLHttpRequest, textStatus){
			$("#"+target).children(".good_loading").hide();
			var newgood;
			if(!jsondata.error_flag){
				newgood = $("#"+target).children(".good_add_area").html()+"<a href=\"http://bestgameon.net/rank/"+jsondata.to_username+"\" ><img class=\"good_new\" src=\"http://bestgameon.net/Bestgame/root/static/images/good_icon.gif\" alt=\"GOOD!アイコン\" title=\""+jsondata.to_username+"\" /></a>";
			} else {
				newgood = $("#"+target).children(".good_add_area").html()+"エラー！";
			}
			$("#"+target).children(".good_add_area").html( newgood );
		},
	});
}

function favorite( to_userid ) {

	var jsondata;

	$("#favorite_button").hide();
	$("#favorite_loading").css({ display:"block" });

	$.ajax({
		dataType: "json",
		data: { 
			"to_userid": to_userid,
		},
		type: "POST",
		url:"http://bestgameon.net/favorite/",
		timeout: 300000,
		success: function (data) { 
			jsondata = data;
		},
		error: function (data,status,errorThrown){
			jsondata = data;
		},
		complete: function (XMLHttpRequest, textStatus){
			$("#favorite_loading").hide();
			if(!jsondata.error_flag){
				$("#unfavorite_button").show();
			} else {
				$("#favorite_error").show();
			}
		},
	});
}

function unfavorite( to_userid ) {

	var jsondata;

	$("#unfavorite_button").hide();
	$("#favorite_loading").css({ display:"block" });

	$.ajax({
		dataType: "json",
		data: { 
			"to_userid": to_userid,
		},
		type: "POST",
		url:"http://bestgameon.net/unfavorite/",
		timeout: 300000,
		success: function (data) { 
			jsondata = data;
		},
		error: function (data,status,errorThrown){
			jsondata = data;
		},
		complete: function (XMLHttpRequest, textStatus){
			$("#favorite_loading").hide();
			if(!jsondata.error_flag){
				$("#favorite_button").show();
			} else {
				$("#favorite_error").show();
			}
		},
	});
}


function goodget_add( userid, page, max_count, page_target ) {

	var htmldata;

	$("#goodget_add_button").hide();
	$("#goodget_loading").show();

	$.ajax({
		dataType: "text",
		type: "GET",
		url:"http://bestgameon.net/goodget/"+userid+"/"+page+"/2",
		timeout: 300000,
		success: function (data) { 
			htmldata = data;
		},
		error: function (data,status,errorThrown){
			htmldata = data;
		},
		complete: function (XMLHttpRequest, textStatus){
			$("#goodget_add_area").html( $("#goodget_add_area").html()+htmldata );
			$("#goodget_loading").hide();
			if( page+1 < max_count / 5 ) {
				$('#'+page_target).attr('value', page+2);
				$("#goodget_add_button").show();
			}
		},
	});
}

function goodgive_add( userid, page, max_count, page_targive ) {

	var htmldata;

	$("#goodgive_add_button").hide();
	$("#goodgive_loading").show();

	$.ajax({
		dataType: "text",
		type: "give",
		url:"http://bestgameon.net/goodgive/"+userid+"/"+page+"/2",
		timeout: 300000,
		success: function (data) { 
			htmldata = data;
		},
		error: function (data,status,errorThrown){
			htmldata = data;
		},
		complete: function (XMLHttpRequest, textStatus){
			$("#goodgive_add_area").html( $("#goodgive_add_area").html()+htmldata );
			$("#goodgive_loading").hide();
			if( page+1 < max_count / 5 ) {
				$('#'+page_targive).attr('value', page+2);
				$("#goodgive_add_button").show();
			}
		},
	});
}

function resget_add( userid, page, max_count, page_target ) {

	var htmldata;

	$("#resget_add_button").hide();
	$("#resget_loading").show();

	$.ajax({
		dataType: "text",
		type: "GET",
		url:"http://bestgameon.net/resget/"+userid+"/"+page+"/2",
		timeout: 300000,
		success: function (data) { 
			htmldata = data;
		},
		error: function (data,status,errorThrown){
			htmldata = data;
		},
		complete: function (XMLHttpRequest, textStatus){
			$("#resget_add_area").html( $("#resget_add_area").html()+htmldata );
			$("#resget_loading").hide();
			if( page+1 < max_count / 5 ) {
				$('#'+page_target).attr('value', page+2);
				$("#resget_add_button").show();
			}
		},
	});
}

function resgive_add( userid, page, max_count, page_targive ) {

	var htmldata;

	$("#resgive_add_button").hide();
	$("#resgive_loading").show();

	$.ajax({
		dataType: "text",
		type: "give",
		url:"http://bestgameon.net/resgive/"+userid+"/"+page+"/2",
		timeout: 300000,
		success: function (data) { 
			htmldata = data;
		},
		error: function (data,status,errorThrown){
			htmldata = data;
		},
		complete: function (XMLHttpRequest, textStatus){
			$("#resgive_add_area").html( $("#resgive_add_area").html()+htmldata );
			$("#resgive_loading").hide();
			if( page+1 < max_count / 5 ) {
				$('#'+page_targive).attr('value', page+2);
				$("#resgive_add_button").show();
			}
		},
	});
}
