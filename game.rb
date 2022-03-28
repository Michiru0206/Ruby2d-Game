require 'ruby2d'

set title: 'Get Yellow Star!'

class Paddle
    attr_writer :direction

    def initialize(side)
        @direction = nil
        @x = 250
        if side == :down
            @y = 420
        else 
            @y = 40
        end
    end

    def draw
        @shape = Rectangle.new(x: @x, y: @y, width: 150, height: 25, color: 'white')
    end

    def move
        if @direction == :right
            @x = [@x + 3.5, max_x].min
        elsif @direction == :left
            @x = [@x - 3.5, 0].max
        end
    end

    # check whether start hits the paddle
    def hit_star?(star)
        star.shape && [[star.shape.x1, star.shape.y1], [star.shape.x2, star.shape.y2], 
        [star.shape.x3, star.shape.y3], [star.shape.x4, star.shape.y4]].any? do |coordinates|
            @shape.contains?(coordinates[0], coordinates[1])
        end
    end

    # check whether start 2 hits the paddle
    def hit_star2?(star2)
        star2.shape && [[star2.shape.x1, star2.shape.y1], [star2.shape.x2, star2.shape.y2], 
        [star2.shape.x3, star2.shape.y3], [star2.shape.x4, star2.shape.y4]].any? do |coordinates|
            @shape.contains?(coordinates[0], coordinates[1])
        end
    end

    # check whether fake star hits the paddle
    def hit_fake?(fake_star)
        fake_star.shape && [[fake_star.shape.x1, fake_star.shape.y1], [fake_star.shape.x2, fake_star.shape.y2], 
        [fake_star.shape.x3, fake_star.shape.y3], [fake_star.shape.x4, fake_star.shape.y4]].any? do |coordinates|
            @shape.contains?(coordinates[0], coordinates[1])
        end
    end

    private

    def max_x
        Window.width - 150
    end
end

class Star
    attr_reader :shape
    SIZE = 25
    def initialize
        @x = rand(25..615)
        @y = rand(0..200)
        #@x = rand(Window.width)
        #@y = rand(Window.height)
        @y_velocity = 3.5
        @x_velocity = -3.5
    end
    
    def draw
        @shape = Square.new(x: @x, y: @y, size: SIZE, color: 'yellow')
    end

    def move
        if hit_left? || hit_right?
            @x_velocity = -@x_velocity
        elsif hit_top?
            @y_velocity = -@y_velocity
        end

        @x = @x + @x_velocity
        @y = @y + @y_velocity
    end

    def stop
        @x_velocity = 0
        @y_velocity = 0
    end

    def end_game
        @x_velocity = 0
        @y_velocity = 0
        @message = Text.new("See You Again!", x: 250, y:240, size: 40, color: 'white')
    end

    def bounce
        @y_velocity = -@y_velocity
    end

    def out?
        @shape.y3 >= Window.height 
    end

    private

    def hit_left?
        @x <= 0 
    end

    def hit_right?
        @x + SIZE >= Window.width
    end

    def hit_top?
        @y <= 0
    end
end

class FakeStar
    attr_reader :shape
    SIZE = 25

    def initialize
        @x = rand(25..615)
        @y = rand(0..200)
        #@x = rand(Window.width)
        #@y = rand(Window.height)
        @y_velocity = 2.5
        @x_velocity = -2.5
    end
    
    def draw
        @shape = Square.new(x: @x, y: @y, size: SIZE, color: 'green')
    end

    def move
        if hit_left? || hit_right?
            @x_velocity = -@x_velocity
        elsif hit_top?
            @y_velocity = -@y_velocity
        end

        @x = @x + @x_velocity
        @y = @y + @y_velocity
    end

    def stop
        @x_velocity = 0
        @y_velocity = 0
    end

    def bounce
        @y_velocity = -@y_velocity
    end

    def out?
        @shape.y3 >= Window.height
    end

    private

    def hit_left?
        @x <= 0 
    end

    def hit_right?
        @x + SIZE >= Window.width
    end

    def hit_top?
        @y <= 0
    end
end


player = Paddle.new(:down)
star = Star.new
star2 = Star.new
fake_star = FakeStar.new
num_point = 0
num_deduct = 0
background = Image.new('night_sky.jpg', width: 640, height: 480)


update do
    clear
    
    # QUESTION: the objects' speeds get slow when I use an image for the background

    set_background = background

    # Add 1 point when paddle hits either star or star2 
    if player.hit_star?(star)
        #star.bounce
        num_point += 1
        @score_board.text = "Score: #{num_point}, Deduction: #{num_deduct}"
        star = Star.new
    end

    if player.hit_star2?(star2)
        num_point += 1
        @score_board.text = "Score: #{num_point}, Deduction: #{num_deduct}"
        star2 = Star.new
    end

    # Deduct 1 point if paddle hits the fake star
    if player.hit_fake?(fake_star)
        num_point -= 1
        num_deduct += 1
        @score_board.text = "Score: #{num_point}, Deduction: #{num_deduct}"
        fake_star = FakeStar.new
    end

    # create score board
    @score_board = Text.new("Score: #{num_point}, Deduction: #{num_deduct}", x: 30, y: 20, size: 25, color: 'white')

    player.move
    player.draw

    star.move
    star.draw

    star2.move
    star2.draw

    fake_star.move
    fake_star.draw

    # game over if one the starts go out the window
    if star.out? || star2.out?
        star.stop
        star2.stop
        fake_star.stop
        message = Text.new("Game Over", x: 220, y: 220, size: 40, color: 'white')
    end

    # redraw fake star if it goes out the window
    if fake_star.out?
        fake_star = FakeStar.new
    end
end

# move paddle in the user specified direction
on :key_held do |event|
    if event.key == 'left'
        player.direction = :left
    elsif event.key == 'right'
        player.direction = :right
    end
end

# stop moving the paddle if key is up
on :key_up do |event|
    player.direction = nil
end

# quit game if user presses 'q'
on :key_down do |event|
    if event.key == 'q'
        star.stop
        star2.stop
        fake_star.stop
        close
    end
end

show