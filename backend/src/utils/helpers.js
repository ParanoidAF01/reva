export const parseTimeString = (timeString) => {
    const unit = timeString.slice(-1);
    const value = parseInt(timeString.slice(0, -1));

    switch (unit) {
        case 's': return value * 1000;
        case 'm': return value * 60 * 1000;
        case 'h': return value * 60 * 60 * 1000;
        case 'd': return value * 24 * 60 * 60 * 1000;
        case 'w': return value * 7 * 24 * 60 * 60 * 1000;
        case 'y': return value * 365 * 24 * 60 * 60 * 1000;
        default: return value * 1000;
    }
};

export const generateOTP = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};