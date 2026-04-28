export const formatTime = (date) => {
    const diff = Math.floor((new Date() - new Date(date)) / 1000);

    if (diff < 60) return `${diff}s ago`;
    if (diff < 3600) return `${Math.floor(diff / 60)} min ago`;
    if (diff < 86400) return `${Math.floor(diff / 3600)} hr ago`;

    return `${Math.floor(diff / 86400)} days ago`;
};