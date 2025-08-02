import { AppError } from "./errorHandler.js";

// Validation helper
export const validateRequest = (schema) => {
    return (req, res, next) => {
        const { error } = schema.validate(req.body);
        if (error) {
            const errorMessage = error.details.map(detail => detail.message).join(', ');
            return next(new AppError(errorMessage, 400));
        }
        next();
    };
};

// Common validation patterns
export const validationPatterns = {
    email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
    mobileNumber: /^[0-9]{10}$/,
    mpin: /^[0-9]{4,6}$/,
    otp: /^[0-9]{6}$/,
    name: /^[a-zA-Z\s]{2,50}$/,
    password: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/
};

// Validation messages
export const validationMessages = {
    email: 'Please provide a valid email address',
    mobileNumber: 'Please provide a valid 10-digit mobile number',
    mpin: 'MPIN must be 4-6 digits',
    otp: 'OTP must be 6 digits',
    name: 'Name must be 2-50 characters long and contain only letters and spaces',
    password: 'Password must be at least 8 characters with uppercase, lowercase, and number',
    required: (field) => `${field} is required`,
    minLength: (field, min) => `${field} must be at least ${min} characters`,
    maxLength: (field, max) => `${field} must be no more than ${max} characters`,
    invalidFormat: (field) => `Invalid ${field} format`
};

// Custom validation functions
export const validators = {
    isValidEmail: (email) => validationPatterns.email.test(email),
    isValidMobileNumber: (mobile) => validationPatterns.mobileNumber.test(mobile),
    isValidMpin: (mpin) => validationPatterns.mpin.test(mpin),
    isValidOtp: (otp) => validationPatterns.otp.test(otp),
    isValidName: (name) => validationPatterns.name.test(name),
    isValidPassword: (password) => validationPatterns.password.test(password)
}; 