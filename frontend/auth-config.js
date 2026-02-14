window.API_CONFIG = { baseUrl: 'https://api-view.cathiefish.org' };

/**
 * Google OAuth Configuration
 * Configure your Google OAuth Client ID here
 * Access control is managed via the test users list in GCP Console
 */

const AUTH_CONFIG = {
    // Client ID obtained from GCP Console
    // Replace with your actual Client ID
    clientId: '136939086552-bt28icv34nucmjna8hfndr6bopr5qcp4.apps.googleusercontent.com',

    // Authentication success callback
    onSuccess: (user) => {
        console.log('Authentication successful:', user.email);
        // Additional logic can be added here, e.g. logging
    },

    // Authentication failure callback
    onError: (error) => {
        console.error('Authentication error:', error);
        // Error handling logic can be added here
    }
};

// Export configuration
window.AUTH_CONFIG = AUTH_CONFIG;
