using Godot;
using System;

public partial class player : CharacterBody2D
{
	public Vector2 velocity;
	public const float Speed = 2500.0f;
	public const float JumpVelocity = -400.0f;

	private AnimatedSprite2D animatedSprite;
	private bool isMoving = false;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();

	public override void _Ready()
	{
		animatedSprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
	}

	public override void _Process(double delta)
	{
		SetAnimationBools();
		PlayAnimations();
	}

	public override void _PhysicsProcess(double delta)
	{
		velocity = Velocity;

		// Add the gravity.
		if (!IsOnFloor())
			velocity.Y += gravity * (float)delta;

		// Handle Jump.
		if (Input.IsActionJustPressed("ui_accept") && IsOnFloor())
			velocity.Y = JumpVelocity;

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
		if (direction != Vector2.Zero)
		{
			velocity.X = direction.X * Speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed/2);
		}

		Velocity = velocity;
		MoveAndSlide();
	}

	private void SetAnimationBools()
	{
		if (velocity.X != 0)
		{
			isMoving = true;
		}
		else
		{
			isMoving = false;
		}
	}

	private void PlayAnimations()
	{
		if (isMoving)
		{
			//
		}
		else if (!isMoving)
		{
			animatedSprite.Play("Idle");
		}
	}

}
