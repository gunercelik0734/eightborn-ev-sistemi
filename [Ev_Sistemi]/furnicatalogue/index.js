var hasFilled = false;
$(function() {
  window.addEventListener('message', function(event) {
    if (event.data.type == "openUI") {
      document.body.style.display = event.data.enable ? "block" : "none";
      if (event.data.enable == true) {
        if (hasFilled == false)
        {
          hasFilled = true;
          for (i=0;i<event.data.shopData.length;i++)
          {
            var newStr = event.data.shopData[i][2].concat(".jpg");
            var newDiv = document.createElement("button");
            newDiv.className = "grid-item";
            newDiv.style.color = "white";
            newDiv.style.fontSize = 20;
            newDiv.style.fontFamily = "courier";
            newDiv.style.fontStyle = "bold";
            newDiv.style.backgroundImage = "url(img/"+newStr+")";
            newDiv.style.backgroundPosition = "center";
            newDiv.style.backgroundSize = "cover";

            newDiv.innerHTML = event.data.shopData[i][0].concat("<br>Price: $",event.data.shopData[i][1])

            var currentDiv = document.getElementById("grid-container");
            currentDiv.appendChild(newDiv);
          }
        }
      }
    }
  });

  $(document).mousedown(function(event) {
      var element = $(document.elementFromPoint(event.pageX - 1, event.pageY - 1));
      if (element[0] == "[object HTMLButtonElement]")
      {
        $.post('http://furnicatalogue/dopost', JSON.stringify(element[0].innerHTML));
      }
  });

  document.onkeyup = function (data) {
    if (data.which == 27) { // Escape key
      $.post('http://furnicatalogue/escape', JSON.stringify({}));
    }
  };
});
