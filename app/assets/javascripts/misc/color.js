var BFColor = {

	getLuminosity: function(color) {
		var c = color.substring(1); 

		if (c.length == 3) {
			var c1 = c.charAt(0);
			var c2 = c.charAt(1);
			var c3 = c.charAt(2);
			c = c1 + c1 + c2 + c2 + c3 + c3;
		}

		var rgb = parseInt(c, 16);
		var r = (rgb >> 16) & 0xff;
		var g = (rgb >> 8) & 0xff;
		var b = (rgb >> 0) & 0xff;

		var luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;

		return luma;
	}
	
};