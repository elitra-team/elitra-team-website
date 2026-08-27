export interface UserProfile {
	id: string;
	auth_id: string;
	display_name: string;
	username: string | null;
	email: string | null;
	avatar_url: string | null;
	admin: boolean;
	tomato_type: string;
	tomato_color: string;
	created_at: string;
	updated_at: string;
}
