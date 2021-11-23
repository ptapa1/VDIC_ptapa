
virtual class shape;
	real width;
	real height;
	
	function new(real w, real h);
		width = w;
		height = h;
	endfunction : new
	
	pure virtual function real get_area();
		//return area;
	//endfunction : get_age
	
	pure virtual function void print();
		//return;
	//endfunction
	
endclass

class rectangle extends shape;
	
	string name = "Rectangle";
	
	function new(real width, real height);
		super.new(.w(width),.h(height));
	endfunction
	
	function real get_area();
		return width*height;
	endfunction
	
	function void print();
		$display("%s w=%g h=%g area=%g", name, width, height, get_area());
	endfunction
	
endclass

class square extends shape;
	
	string name = "Square";
	
	function new(real width);
		super.new(.w(width), .h(width));
	endfunction
	
	function real get_area();
		return width**2;
	endfunction
	
	function void print();
		$display("%s w=%g h=%g area=%g", name, width, height, get_area());
	endfunction
	
endclass

class triangle extends shape;
	
	string name = "Triangle";
	
	function new(real width, real height);
		super.new(.w(width),.h(height));
	endfunction
	
	function real get_area();
		return (width*height)/2;
	endfunction
	
	function void print();
		$display("%s w=%g h=%g area=%g", name, width, height, get_area());
	endfunction
	
endclass





class shape_reporter #(type T = shape);
	
	protected static T shape_storage [$];
	
	static function void shape_store(T l);
      shape_storage.push_back(l);
   	endfunction
		
	static function void report_shapes();
		real area_sum=0, area=0;
		foreach (shape_storage[i]) begin
			shape_storage[i].print();
			area=shape_storage[i].get_area();
			area_sum = area_sum + area;	
		end 
		$display("Total area: %g\n", area_sum);
	endfunction
endclass

class shape_factory;
	
	static function shape make_shape (string shape_type, real w, real h);
	
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		
		case(shape_type)
			"rectangle": begin
				rectangle_h = new(w, h);
				shape_reporter #(rectangle)::shape_store(rectangle_h);
				return rectangle_h;
			end 
		
			"square": begin
				square_h = new(w);
				shape_reporter #(square)::shape_store(square_h);
				return square_h;
			end  
			
			"triangle": begin
				triangle_h = new(w, h);
				shape_reporter #(triangle)::shape_store(triangle_h);
				return triangle_h;
			end  
		endcase
	endfunction
endclass


module top;


   initial begin
	  
	  shape shape_h;
	  
	  int file, status;
	  string shape_type;
	  real w,h;
	  
      file = $fopen("./lab04part1_shapes.txt","r");
	  
	  while(!$feof(file)) begin
		 status =  $fscanf(file,"%s %g %g\n", shape_type, w, h);
		  
		 shape_h = shape_factory :: make_shape(shape_type, w, h);
	  end
	  	
	  shape_reporter #(rectangle)::report_shapes();
      shape_reporter #(square)::report_shapes();
      shape_reporter #(triangle)::report_shapes();
	  
   end

endmodule : top
