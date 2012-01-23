$(function(){

	$(".item_click").click(function(){
		itemselect($(this).parent().parent().parent().parent().children(".target_searchbox").attr("value"), $(this).children("#Asin").attr('value'), $(this).children("#title").attr('value'), $(this).children("#ImageUrlSmall").attr('value'));
	})

	$(".paging_edit").click(function(){
		amazonsearch($(this).children("#keyword").attr('value'),'#'+$(this).parent().parent().parent().parent().get(0).id,$(this).children("#page").attr('value'),'amazon');
	})

})