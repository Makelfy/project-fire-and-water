using Godot;

public partial class Knockback : Area2D
{
	private const float Speed = 150.0f;

	[Export]
	public float Distance { get; set; }

	private float _defaultPositionX;
	private int _direction = 1;

	public override void _Ready()
	{
		_defaultPositionX = GlobalPosition.X;
	}

	public override void _PhysicsProcess(double delta)
	{
		if (Mathf.Abs(_defaultPositionX - GlobalPosition.X) <= Distance)
		{
			GlobalPosition += new Vector2(Speed * (float)delta * _direction, 0);
			return;
		}

		_direction *= -1;
		GlobalPosition += new Vector2(_direction * 10.0f, 0);

		if (GetNodeOrNull<Sprite2D>("Sprite2D") is Sprite2D sprite)
		{
			sprite.FlipH = _direction != -1;
		}
	}

	public void _on_body_entered(Node2D body)
	{
		if (!body.IsInGroup("player"))
		{
			return;
		}

		if (body.GetChildOrNull<Sprite2D>(0) is Sprite2D sprite)
		{
			sprite.Modulate = new Color(1.0f, 0.0f, 0.0f, 1.0f);
		}

		body.Call("start_timer");

		if (body.HasMethod("apply_knockback"))
		{
			body.Call("apply_knockback", GlobalPosition);
		}
	}
}
