// Example autocalc for BMI for the background form.

// The main purpose of this is to set up event handlers that calculate the
// value for BMI based on the form elements sbph, sbphu, sbpw and sbpwu
// (height, height units, weight and weight units, respectively). It's just an
// example, and hastily coded at that. It's also raw JavaScript without any
// concern for compatibility; if I were going to do this in a cross-platform
// way, I'd use a framework like jQuery that would handle that stuff for me.

document.addEventListener( "DOMContentLoaded", function(){

  // Get the first form element; for the SAMI forms, this will always be the
  // first form.

  var bgform = document.forms.backgroundForm;

  // If this is the background form . . .

  if (bgform) {
    var changeFunc = function(){
      var ht = bgform.sbph.value * (bgform.sbphu.value == "i" ? 0.0254 : 0.01),
          wt = bgform.sbpw.value * (bgform.sbpwu.value == "p" ? 0.4535 : 1),
          bmi = wt / (ht * ht);
      if( ht > 0 && wt > 0 ) {
        bgform.sbbmi.value = bmi.toFixed(1);
      } else {
        bgform.sbbmi.value = "";
      }
      bgform.sbbmivis.value = bgform.sbbmi.value;
    };
    // Assign the same onchange to the weight box.
    bgform.sbph.onchange = changeFunc;
    bgform.sbpw.onchange = changeFunc;
    // And to each of the radio buttons.
    for (var i = 0, len = bgform.sbphu.length; i < len; i++) {
      bgform.sbphu[i].onclick = changeFunc;
    }
    for (var i = 0, len = bgform.sbpwu.length; i < len; i++) {
      bgform.sbpwu[i].onclick = changeFunc;
    }
    // Oh. Yeah. And execute it since we have the form loaded.
    changeFunc();
  }

} );
