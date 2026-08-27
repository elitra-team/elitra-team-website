declare global {
	namespace App {
		interface Error {
			message: string;
		}
		// eslint-disable-next-line @typescript-eslint/no-empty-object-type
		interface Locals {}
		interface PageData {
			session: import('@supabase/supabase-js').Session | null;
			user: import('$lib/types').UserProfile | null;
		}
		// eslint-disable-next-line @typescript-eslint/no-empty-object-type
		interface PageState {}
		// eslint-disable-next-line @typescript-eslint/no-empty-object-type
		interface Platform {}
	}
}

export {};
