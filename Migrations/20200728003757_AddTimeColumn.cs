using Microsoft.EntityFrameworkCore.Migrations;

namespace MarshallAPI.Migrations
{
    public partial class AddTimeColumn : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Time",
                table: "Slots",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Time",
                table: "Slots");
        }
    }
}
