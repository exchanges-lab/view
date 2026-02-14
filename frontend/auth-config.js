window.API_CONFIG = { baseUrl: 'https://xxx.xxx.com' };

const AUTH_CONFIG = {
    clientId: 'xxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
    onSuccess: (user) => {
        console.log('Authentication successful:', user.email);
    },
    onError: (error) => {
        console.error('Authentication error:', error);
    }
};

window.AUTH_CONFIG = AUTH_CONFIG;
window.ALLOWED_EMAILS = ['your-email@gmail.com'];
