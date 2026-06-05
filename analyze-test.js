import http from 'k6/http';

export const options = {
  vus: 20,
  duration: '30s',
};

export default function () {
  const payload = JSON.stringify({
    text: `movie review ${Math.random()}`,
    movie_name: "Interstellar"
  });

  http.post(
    'http://localhost:8000/analyze',
    payload,
    {
      headers: {
        'Content-Type': 'application/json',
      },
    }
  );
}
