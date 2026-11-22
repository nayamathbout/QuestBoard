# QuestBoard

QuestBoard is a web-based gamified habit and productivity tracker. It helps users manage their quests and keep track of their progress while staying motivated.

## Features
- Registration system
- Login system (sessions)
- Tasks/quests system with timing and recurrence
- Rewards and levels
- Streaks
- In-game store

## Installation (via bash)
- `npm install`

All required dependencies are included in `package.json`.

## Database configuration

Copy `config/questboard.example.json` and rename the copy to `config/questboard.json`.

Fill in your local database credentials:

```json
{
    "host": "localhost",
    "user": "your_database_username",
    "password": "your_database_password",
    "database": "QuestBoard",
    "multipleStatements": true
}
```

The original `questboard.json` file is excluded from Git through `.gitignore`.

## Database setup

Run the following commands in order from the project root.

**Note:** `setup.sql` drops and recreates the `QuestBoard` database, deleting any existing data.

1. Create the database using a MariaDB account with permission to create databases:

   ```bash
   sudo mariadb < sql/setup.sql
   ```

2. Make sure your MariaDB user has the necessary permissions on the `QuestBoard` database. Use the same username and password specified in `config/questboard.json`.

3. Create the tables:

   ```bash
   mariadb -u your_database_username -p QuestBoard < sql/ddl.sql
   ```

4. Enable the event scheduler:

   ```bash
   sudo mariadb
   ```

   Then run:

   ```sql
   SET GLOBAL event_scheduler = ON;
   EXIT;
   ```

5. Create the stored procedures, functions, triggers, and events:

   ```bash
   mariadb -u your_database_username -p QuestBoard < sql/functions.sql
   ```

6. Insert the initial data:

   ```bash
   mariadb -u your_database_username -p QuestBoard < sql/insert.sql
   ```

The event scheduler must be enabled for scheduled database events to run.

## Session configuration

Create a `.env` file in the project root:

```env
SESSION_SECRET=your_random_session_secret
```

You can generate a random secret using:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Replace the placeholder with the generated value.

The `.env` file is excluded from Git.

## Running the application
- Run `npm start` or `node index.js`.
- Open your browser and go to: `http://localhost:1337/QuestBoard`

## Vitest
- `npm test`

## Smoke test
- Start the application first.
- Run `npm run smoke`.

## Manually test the application
- Open `http://localhost:1337/QuestBoard`.
- You must be redirected to `QuestBoard/login`.
- Click on "Sign Up" to be redirected to `QuestBoard/signup`.
- Create an account by entering your name, email, and a password that follows the listed conditions.
- You will be redirected to `QuestBoard/account_created`. Click on "Log In".
- Log in by entering the email and password you've just created an account with.
- You will be redirected to `QuestBoard/dashboard`.
- Click on "Create a Quest" to be redirected to `QuestBoard/quest`.
- Create a quest by filling in the form and submitting it.
- When redirected to the dashboard, complete the quest by clicking on "Complete" next to the quest's row in the "Upcoming Quests" table.
- You will get XP and coins.
- To learn the conditions for rewards, such as how many coins and XP you get and the rules for badges and streaks, open "Information" from the header.
- Open your profile by clicking on "Profile" to view your information, completed quests, and rewards (rewards can also be viewed on the dashboard).
- You can test editing your quest by clicking on "Edit" next to the quest in the Upcoming Quests table on the dashboard and choosing which part you would like to edit.
- You can delete a quest by clicking on "Delete" next to the quest in the Upcoming Quests table on the dashboard.
- You can change your bio and profile picture from the profile by clicking on the corresponding action button.
- Open the shop by clicking on "Store" in the header.
- When redirected to the store, click on "Buy" to purchase an avatar.
- You can view your owned avatars in the profile.
- Finally, click on "Log Out" in the header to log out of the session and be redirected to the login page.

## Prototype overview

## Routing logic
- `header2` has links to `QuestBoard/login` and `QuestBoard/signup` for users before logging in.
- `/QuestBoard` redirects you to `QuestBoard/login` without rendering a page.
- `/QuestBoard/login` is where you log in.
- `/QuestBoard/signup` is where you submit a form and get redirected to `/QuestBoard/account_created`.
- In `/QuestBoard/account_created`, there is a link to `QuestBoard/login`.
- `/QuestBoard/dashboard` can only be accessed after submitting the login form in `QuestBoard/login`.
- Header links are only accessible after logging in. They are: `QuestBoard/profile`, `QuestBoard/dashboard`, `QuestBoard/store`, `QuestBoard/information`, and `QuestBoard/logout`.
- There are 4 route actions in `QuestBoard/dashboard`:
  - Links: `QuestBoard/quest`, `QuestBoard/profile`, `QuestBoard/edit_quest`, `QuestBoard/add_description`.
  - Action: `QuestBoard/delete_quest`, which performs a POST action and redirects you to `QuestBoard/dashboard`.
- `QuestBoard/profile` has 4 links: `QuestBoard/add_description`, `QuestBoard/add_birthday`, `QuestBoard/update_bio`, and `QuestBoard/change_avatar`.
- `QuestBoard/update_bio` redirects you back to `QuestBoard/profile`.
- `QuestBoard/add_birthday` redirects you back to `QuestBoard/profile`.
- `QuestBoard/change_avatar` redirects you back to `QuestBoard/profile`.
- `QuestBoard/add_description` redirects you to `QuestBoard/dashboard`.
- `QuestBoard/edit_quest` has 3 links: `QuestBoard/edit_name`, `QuestBoard/edit_description`, and `QuestBoard/edit_type`.
- All three links redirect you to `QuestBoard/dashboard` after submitting their forms.
- QuestBoard information has no links (other than the header links).
- `QuestBoard/logout` only redirects you to `QuestBoard/login` and logs you out of the session without rendering a page.

## Registration/login system functionality
- In the database, there are two tables: `inlogging` and `profiles`.
- `inlogging` has email, hashed password (managed by bcrypt), and user ID.
- `profiles` has other information such as name, birthday, profile picture ID, etc.
- When signing up, the app checks if the email is unique and if the password follows the conditions. If so, the app inserts the user information into the database.
- When logging in, the app checks if the email and password are correct and logs the user in using the session system.
- Edits are made via stored procedures (for example, updating the profile picture).

## Avatar/store system
- In the database, there are two tables: `store` and `owned_items`.
- `store` has information on the items the app sells.
- `owned_items` links the item ID with the user ID of the person who owns the item.
- When a user buys an item, the app inserts the item ID and user ID into the `owned_items` table.

## Quest system functionality
- In the database, there are two tables: `quests` and `completed_quests`.
- When the user creates a quest, the app links it to the user with `user_id` and inserts it into the `quests` table.
- The app sets the due time based on the quest type.
- When completing a quest, the app changes the status of the quest.
- The app inserts the quest into the `completed_quests` table.
- After midnight (for daily quests) or 7 days after creation (for weekly quests), the app resets the due time via events.
- Edits are made via stored procedures.

## Streak system
- In the database, there are two tables: `streaks` and `ongoing_streaks`.
- The `streaks` table has information on the streaks.
- `ongoing_streaks` links the streak ID with the user ID and the last login date.
- When logging in, the app checks the last login date. If it's the same date, the app does nothing. If it's the very next day, the app adds 1 to the streak. If it's more than a day later, the app resets the streak to 1.
- When completing a quest, the app checks the status. If it was late, the app resets the streak to 1. If it's early or on time, the app adds 1.

## Badges
- In the database, there are two tables: `badges` and `owned_badges`.
- The `owned_badges` table links the badge from the `badges` table to the user ID from the `profiles` table.
- Users get badges via triggers.

## Project structure

```text
QuestBoard/
│
├── index.js                    # Main application file
├── package.json                # Dependencies and scripts
├── package-lock.json           # Dependency lock file
├── middleware/                 # Middleware
├── functions/                  # JavaScript functions
├── route/                      # Route file
├── views/                      # EJS templates, CSS, and images
├── public/                     # Public assets
├── config/                     # Database configuration example
│   └── questboard.example.json
├── route.test.js               # Tests
├── sql/                        # SQL files
├── .gitignore                  # Excluded files
└── README.md                   # Project documentation
```

`node_modules/`, `.env`, and `config/questboard.json` are local files excluded from Git.

## Tech Stack
- **Backend:** Node.js, Express
- **Frontend:** HTML, CSS, EJS
- **Database:** MariaDB (MySQL-compatible) with `promise-mysql`
- **Testing:** Vitest, Supertest
- **Session handling:** express-session

**Software Engineering student:** Naya Mathbout  
**Acronym:** namt24