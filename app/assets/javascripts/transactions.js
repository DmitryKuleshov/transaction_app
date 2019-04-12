$(document).on("turbolinks:load", function(){ openLink() });

function openLink(){
  $("tr[data-link]").click(function() {
    window.location = $(this).data("link");
  });
}
