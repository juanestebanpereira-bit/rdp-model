Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test

## Project Conventions

### Documentation Files
`doc()` block files (*.md) are located in `models/` rather than the
conventional `docs/` folder. This is intentional — dbt only includes
the `models/` folder when distributing this project as a package via
`dbt deps`. Placing doc files in `models/` ensures they are available
to downstream projects that install `rtl_rdp` as a package.

### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
